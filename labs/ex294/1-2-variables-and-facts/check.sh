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
# hostvar HOST: HOST's http_port as the inventory sees it.
hostvar() { ans ansible-inventory --host "$1" 2>/dev/null | python3 -c 'import json, sys; print(json.load(sys.stdin).get("http_port", ""))'; }
# A host the lab adds to webservers for a moment, to see what the group gives.
printf '[webservers]\nlab-probe\n' >"$T/probe.ini"
probevar() { ans ansible-inventory -i inventory -i "$T/probe.ini" --host lab-probe 2>/dev/null | python3 -c 'import json, sys; print(json.load(sys.stdin).get("http_port", ""))'; }
# fact HOST NAME: a fact as the setup module reports it (JSON for a dictionary).
fact() { ans ansible "$1" -m ansible.builtin.setup -a "filter=ansible_$2" 2>/dev/null | sed '1s/^[^{]*//' | python3 -c 'import json, sys
v = json.load(sys.stdin)["ansible_facts"]["ansible_" + sys.argv[1]]
print(v if isinstance(v, (str, int)) else json.dumps(v))' "$2"; }
# shows NAME HOST VALUE: a debug task of the play printed VALUE on HOST.
shows() { [ -n "$3" ] && js "$1" "any(debug(e) and has(e, '$3') for e in ev('$2'))"; }
# facts_shown HOST: facts.yml printed HOST's distribution, version and memory.
facts_shown() {
	local f
	for f in distribution distribution_version memtotal_mb; do shows facts "$1" "$(fact "$1" $f)" || return 1; done
}
role_fact() { fact node1 local | python3 -c 'import json, sys; sys.exit(json.load(sys.stdin)["role"]["general"]["role"] != "web")'; }

task 1 "http_port: 80 for webservers, 8080 for node2, printed by port.yml"
need "webservers hosts get http_port 80 from the group" '[ "$(probevar)" = 80 ]'
need "node1's http_port is 80" '[ "$(hostvar node1)" = 80 ]'
need "node2's http_port is 8080" '[ "$(hostvar node2)" = 8080 ]'
need "/home/greg/ansible/port.yml exists" '[ -f /home/greg/ansible/port.yml ]'
need "ansible-playbook port.yml runs without errors" 'play port port.yml'
need "port.yml prints 80 on node1 and 8080 on node2" 'shows port node1 80 && shows port node2 8080'
need "with -e http_port=9000, port.yml prints 9000 on both" 'play port9 port.yml -e http_port=9000; shows port9 node1 9000 && shows port9 node2 9000'

task 2 "facts.yml prints each node's distribution, version and memory"
need "/home/greg/ansible/facts.yml exists" '[ -f /home/greg/ansible/facts.yml ]'
need "ansible-playbook facts.yml runs without errors" 'play facts facts.yml'
for n in $(nodes_names); do
	need "facts.yml prints the distribution, its version and the memory on $n" "facts_shown $n"
done

task 3 "A custom fact role=web in [general] on node1"
need "node1 has /etc/ansible/facts.d/role.fact" 'in_node node1 test -f /etc/ansible/facts.d/role.fact'
need "the setup module shows role: web under general in ansible_local on node1" role_fact
