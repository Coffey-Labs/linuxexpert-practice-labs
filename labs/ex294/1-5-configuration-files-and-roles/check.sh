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
# cfg_in DIR: the config file ansible --version names, run as greg in DIR.
cfg_in() { timeout 120 runuser -l greg -c "cd $1 && ansible --version" </dev/null 2>/dev/null | sed -n 's/^  config file = //p'; }
# line N: line N of /root/lab-answers/1, with ~ spelled out.
line() { sed -n "${1}p" /root/lab-answers/1 2>/dev/null | sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s|^~/|/home/greg/|'; }
# changed: the settings greg's ansible.cfg changes, by ansible-config's names.
changed() { ans ansible-config dump --only-changed 2>/dev/null | sed -n 's|^\([A-Z_0-9]*\)(/home/greg/ansible/ansible.cfg) = .*|\1|p'; }
all_named() {
	local s n=0
	for s in $(changed); do grep -qw "$s" /root/lab-answers/2 || return 1; n=$((n + 1)); done
	[ "$n" -gt 0 ]
}
has_default() { python3 -c 'import sys, yaml; d = yaml.safe_load(open(sys.argv[1])); sys.exit(not (isinstance(d, dict) and "motd_text" in d))' $P/roles/motd/defaults/main.yml; }
W=Hello-from-check-$RANDOM
cat >>"$T/q.py" <<'X'
def motd(h):
    return [e for e in ev(h) if e['role'] == 'motd']
X

task 1 "The ansible.cfg in use in ~/ansible and in /tmp, in /root/lab-answers/1"
need "line 1 of /root/lab-answers/1 is the file Ansible uses in /home/greg/ansible" '[ -n "$(line 1)" ] && [ "$(line 1)" = "$(cfg_in /home/greg/ansible)" ]'
need "line 2 of /root/lab-answers/1 is the file Ansible uses in /tmp" '[ -n "$(line 2)" ] && [ "$(line 2)" = "$(cfg_in /tmp)" ]'

task 2 "The settings greg's ansible.cfg changes, in /root/lab-answers/2"
need "/root/lab-answers/2 names every setting ansible-config dump --only-changed shows from greg's file" all_named

task 3 "A role motd writes /etc/motd from a default variable, on every node"
need "/home/greg/ansible/roles/motd/tasks/main.yml exists" "[ -f $P/roles/motd/tasks/main.yml ]"
need "the role's defaults/main.yml sets motd_text" has_default
need "/home/greg/ansible/motd.yml exists" "[ -f $P/motd.yml ]"
need "ansible-playbook motd.yml --check runs the role on every node, with nothing left to change" 'play motd motd.yml --check --diff; js motd "set(S) >= {\"node1\", \"node2\"} and all(motd(h) for h in S) and all(S[h][\"changed\"] == 0 and S[h][\"failures\"] == 0 for h in S)"'
need "/etc/motd isn't empty on node1 and node2" 'in_node node1 test -s /etc/motd && in_node node2 test -s /etc/motd'
need "with -e motd_text=TEXT, the role would write TEXT to /etc/motd on every node" 'play motdx motd.yml --check --diff -e motd_text=$W; js motdx "all(any(e[\"status\"] == \"changed\" and \"$W\" in text(e) for e in motd(h)) for h in S)"'
