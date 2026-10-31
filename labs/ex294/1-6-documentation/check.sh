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
P=/home/greg/ansible
F=/etc/ssh/sshd_config
# The uncommented PermitRootLogin lines of node1's sshd_config.
prl() { in_node node1 grep -Ei '^[[:space:]]*PermitRootLogin[[:space:]]' $F; }
has() { grep -Fqi -- "$2" "/root/lab-answers/$1" 2>/dev/null; }

task 1 "ansible.posix installed; the module for SELinux booleans and its persistence option in /root/lab-answers/1"
need "the ansible.posix collection is installed: ansible-doc finds ansible.posix.seboolean as greg" "timeout 120 runuser -l greg -c 'ansible-doc -l ansible.posix' </dev/null 2>/dev/null | grep -q '^ansible.posix.seboolean '"
need "/root/lab-answers/1 names the module, by its full name" 'has 1 ansible.posix.seboolean'
need "/root/lab-answers/1 names the option that makes the change persistent" 'grep -qw persistent /root/lab-answers/1'

task 2 "sshd.yml sets PermitRootLogin no with lineinfile, and a second run is ok"
need "node1's $F has the line PermitRootLogin no" 'prl | grep -Eqi "^[[:space:]]*PermitRootLogin[[:space:]]+no[[:space:]]*$"'
need "node1's $F has no other PermitRootLogin line" '[ "$(prl | wc -l)" = 1 ]'
need "sshd accepts node1's configuration" 'in_node node1 sshd -t'
need "/home/greg/ansible/sshd.yml exists" "[ -f $P/sshd.yml ]"
need "ansible-playbook sshd.yml runs a lineinfile task on node1 without errors" 'play sshd sshd.yml; js sshd "any(e[\"action\"].split(\".\")[-1] == \"lineinfile\" for e in ev(\"node1\")) and S[\"node1\"][\"failures\"] == 0"'
need "running sshd.yml again changes nothing (ok)" 'js sshd "S[\"node1\"][\"changed\"] == 0"'

task 3 "The filter that hashes passwords, in /root/lab-answers/3"
need "/root/lab-answers/3 names the filter" 'has 3 password_hash'
