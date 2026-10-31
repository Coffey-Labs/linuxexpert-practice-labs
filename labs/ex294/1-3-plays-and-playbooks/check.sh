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
def diffs(e):
    x = e['result'].get('diff', [])
    return x if isinstance(x, list) else [x]
def page(x):
    return '/var/www/html/' in str(x.get('after_header', '')) + str(x.get('before_header', ''))
def page_diffs(e):
    return [x for x in diffs(e) if page(x) and x.get('before') != x.get('after')]
X
# jp NAME EXPR: print a Python expression on the play's results.
jp() { python3 -c "exec(open('$T/q.py').read()); print($2)" "$T/out/$1.json" 2>/dev/null; }
# page: what node1 serves, retrying for up to 15 seconds.
page() {
	local i
	for i in $(seq 15); do curl -fsS --max-time 5 http://node1/ 2>/dev/null && return 0; sleep 1; done
	return 1
}
P=/home/greg/ansible
# One run of site.yml in check mode, for tasks 1 and 2.
[ -f $P/site.yml ] && play site site.yml --check --diff

task 1 "site.yml: httpd with a home page on the webservers, mariadb-server on the dbservers"
need "/home/greg/ansible/site.yml exists" "[ -f $P/site.yml ]"
need "httpd is installed on node1" 'in_node node1 rpm -q httpd'
need "httpd is enabled on node1" 'in_node node1 systemctl is-enabled httpd'
need "httpd is running on node1" 'in_node node1 systemctl is-active httpd'
need "curl http://node1 from the control node prints a page" 'page | grep -q .'
need "mariadb-server is installed on node2" 'in_node node2 rpm -q mariadb-server'
need "site.yml --check runs on node1 and node2 with no failures" 'js site "ev(\"node1\") and ev(\"node2\") and not ev(status=\"failed\") and not ev(status=\"unreachable\")"'
need "another run of site.yml would change nothing but the page (--check)" 'js site "all(page_diffs(e) for e in ev(status=\"changed\"))"'

task 2 "A new page text, previewed on node1 but not made"
need "site.yml --check --diff would change the page on node1" 'js site "any(page_diffs(e) for e in ev(\"node1\", \"changed\"))"'
need "curl http://node1 still prints the old page" '[ "$(page)" = "$(jp site "next(x for e in ev(\"node1\", \"changed\") for x in page_diffs(e))[\"before\"].rstrip()")" ]'

task 3 "broken.yml: a task with bad indentation, the line in /root/lab-answers/3"
need "/home/greg/ansible/broken.yml exists" "[ -f $P/broken.yml ]"
need "ansible-playbook --syntax-check broken.yml fails, naming the file and a line" "! ans ansible-playbook broken.yml --syntax-check >$T/syntax.out 2>&1 && grep -Eq 'broken.yml.: line [0-9]+' $T/syntax.out"
need "/root/lab-answers/3 holds the line number it names" 'grep -qw "$(grep -Eo "broken.yml.: line [0-9]+" $T/syntax.out | grep -Eo "[0-9]+$" | head -n1)" /root/lab-answers/3'
