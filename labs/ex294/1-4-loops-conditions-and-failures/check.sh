nodes_wait 60 || true
# ans CMD: run CMD as greg in his project directory.
ans() { timeout 300 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
# play NAME PLAYBOOK [ARGS]: run one of greg's playbooks with a callback that
# records every result and the recap in $T/out/NAME.json; js NAME EXPR then
# tests a Python expression on them (see $T/q.py).
T=$(mktemp -d); chmod 755 "$T"; trap 'rm -rf "$T"' EXIT
install -d -o greg "$T/out"; mkdir "$T/cb"
cat >"$T/cb/le_lab_record.py" <<'X'
import json
import os

from ansible.plugins.callback import CallbackBase


class CallbackModule(CallbackBase):
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'aggregate'
    CALLBACK_NAME = 'le_lab_record'
    CALLBACK_NEEDS_ENABLED = True

    def __init__(self):
        super().__init__()
        self.events = []

    def _add(self, status, result):
        t = result._task
        r = {k: v for k, v in result._result.items() if k != 'ansible_facts'}
        self.events.append({'host': result._host.get_name(), 'task': t.get_name(), 'action': t.action,
                            'role': t._role.get_name() if t._role else '', 'status': status, 'result': r})

    def v2_runner_on_ok(self, result):
        self._add('changed' if result._result.get('changed') else 'ok', result)

    def v2_runner_on_failed(self, result, ignore_errors=False):
        self._add('ignored' if ignore_errors else 'failed', result)

    def v2_runner_on_skipped(self, result):
        self._add('skipped', result)

    def v2_runner_on_unreachable(self, result):
        self._add('unreachable', result)

    def v2_playbook_on_stats(self, stats):
        out = {'events': self.events, 'stats': {h: stats.summarize(h) for h in stats.processed}}
        with open(os.environ['LE_LAB_JSON'], 'w') as f:
            json.dump(out, f, default=str)
X
cat >"$T/q.py" <<'X'
import json, re, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    sys.exit(1)
E, S = d['events'], d['stats']
def ev(host=None, status=None):
    return [e for e in E if host in (None, e['host']) and status in (None, e['status'])]
def text(e):
    return json.dumps({k: v for k, v in e['result'].items() if not k.startswith('_')})
def debug(e):
    return e['action'].split('.')[-1] == 'debug'
def has(e, word):
    return re.search(r'(?<![\w.])' + re.escape(str(word)) + r'(?![\w.])', text(e)) is not None
X
play() {
	local o=$T/out/$1.json; shift
	rm -f "$o"
	ans "ANSIBLE_CALLBACK_PLUGINS=$T/cb ANSIBLE_CALLBACKS_ENABLED=le_lab_record LE_LAB_JSON=$o ansible-playbook $*" >"$T/out.log" 2>&1
}
js() { python3 -c "exec(open('$T/q.py').read()); sys.exit(0 if ($2) else 1)" "$T/out/$1.json"; }
cat >>"$T/q.py" <<'X'
def items(e):
    return [r.get('item') for r in e['result'].get('results', [])]
def users_loop(e):
    i = items(e)
    return (len(i) >= 2 and all(isinstance(x, dict) for x in i)
            and any('alice' in x.values() for x in i) and any('bob' in x.values() for x in i))
# What a looped result shows, whatever its key (msg, a var's name); with
# var: item, debug's key is the loop's own "item".
LOOP_KEYS = {'item', 'ansible_loop_var', 'ansible_index_var', 'changed', 'failed', 'skipped', 'skip_reason', 'false_condition'}
def shown(e, r):
    s = {k: v for k, v in r.items() if not k.startswith('_') and k not in LOOP_KEYS}
    return s if s or not debug(e) else {'item': r.get('item')}
def pairs_shown(e):
    rs = e['result'].get('results', [])
    return (len(rs) >= 2 and all(isinstance(r.get('item'), dict) and set(r['item']) == {'key', 'value'} for r in rs)
            and all(has({'result': shown(e, r)}, r['item']['key']) and has({'result': shown(e, r)}, r['item']['value']) for r in rs))
def mem_split(h):
    d = [e for e in ev(h) if debug(e)]
    return (any(e['status'] == 'ok' for e in d)
            and any(e['status'] == 'skipped' and 'mem' in str(e['result'].get('false_condition', '')) for e in d))
def failed_after(h):
    # h failed a task, every other host ran a task after that, and only h failed.
    i = next((n for n, e in enumerate(E) if e['host'] == h and e['status'] == 'failed'), None)
    others = [o for o in S if o != h]
    return (i is not None and others and S[h]['failures'] == 1
            and all(S[o]['failures'] == 0 and S[o]['unreachable'] == 0 for o in others)
            and all(any(e['host'] == o and e['status'] in ('ok', 'changed') for e in E[i + 1:]) for o in others))
X
P=/home/greg/ansible

task 1 "alice (in wheel) and bob on node1, from a list of dictionaries in one task"
need "alice is on node1, in wheel" 'in_node node1 id -nG alice | grep -qw wheel'
need "bob is on node1" 'in_node node1 id bob'
need "/home/greg/ansible/users.yml exists" "[ -f $P/users.yml ]"
need "ansible-playbook users.yml runs without errors" 'play users users.yml'
need "one task of users.yml loops over dictionaries for alice and bob on node1" 'js users "any(users_loop(e) for e in ev(\"node1\"))"'
need "running users.yml again changes nothing on node1 (both items ok)" 'js users "S[\"node1\"][\"changed\"] == 0"'

task 2 "memory.yml: one message on hosts with over 2 GiB, another on the rest"
need "/home/greg/ansible/memory.yml exists" "[ -f $P/memory.yml ]"
need "ansible-playbook memory.yml runs without errors" 'play memory memory.yml'
for n in $(nodes_names); do
	need "on $n, one message shows and the other is skipped by a condition on memory" "js memory 'mem_split(\"$n\")'"
done

task 3 "services.yml: print each name and port of a dictionary, with dict2items"
need "/home/greg/ansible/services.yml exists" "[ -f $P/services.yml ]"
need "ansible-playbook services.yml runs without errors" 'play services services.yml'
need "a looped task prints each item.key and item.value of dict2items" 'js services "any(pairs_shown(e) for e in E)"'
need "services.yml uses dict2items" "grep -q dict2items $P/services.yml"

task 4 "fail.yml: a task fails on one host and the others carry on"
need "/home/greg/ansible/fail.yml exists" "[ -f $P/fail.yml ]"
need "ansible-playbook fail.yml reaches every node" 'play fail fail.yml; js fail "set(S) >= {\"node1\", \"node2\"}"'
need "the recap shows failed=1 for one host only, and the others ran tasks after it" 'js fail "any(failed_after(h) for h in S)"'
