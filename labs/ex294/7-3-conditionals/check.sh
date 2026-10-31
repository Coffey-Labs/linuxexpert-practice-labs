nodes_wait 60 || true
OUT=$LAB_STATE/check.out CB=$LAB_STATE/callback
# A stdout callback that writes a play's results as one line of JSON.
mkdir -p "$CB"
cat >"$CB/lab_json.py" <<'X'
import json
from ansible.plugins.callback import CallbackBase
from ansible.playbook.handler import Handler


class CallbackModule(CallbackBase):
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'stdout'
    CALLBACK_NAME = 'lab_json'

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.events = []

    def _add(self, status, result):
        r = result._result
        self.events.append({
            'host': result._host.get_name(), 'task': result._task.get_name(),
            'action': result._task.action, 'status': status,
            'changed': bool(r.get('changed')), 'msg': str(r.get('msg', '')),
            'handler': isinstance(result._task, Handler)})

    def v2_runner_on_ok(self, result):
        self._add('ok', result)

    def v2_runner_on_failed(self, result, ignore_errors=False):
        self._add('ignored' if ignore_errors else 'failed', result)

    def v2_runner_on_skipped(self, result):
        self._add('skipped', result)

    def v2_runner_on_unreachable(self, result):
        self._add('unreachable', result)

    def v2_playbook_on_stats(self, stats):
        s = {h: stats.summarize(h) for h in sorted(stats.processed)}
        self._display.display(json.dumps({'events': self.events, 'stats': s}))
X
chmod -R a+rX "$CB"
# ans CMD: run CMD as greg in his project directory.
ans() { timeout 300 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
# play PLAYBOOK [ARGS]: run a playbook as greg, with its results in $OUT.
play() { rm -f "$OUT"; ans "ANSIBLE_CALLBACK_PLUGINS=$CB ANSIBLE_STDOUT_CALLBACK=lab_json ansible-playbook $*" 2>/dev/null | grep '^{"events"' >"$OUT"; [ -s "$OUT" ]; }
# msgs [HOST]: what debug tasks printed in that run (on HOST), one a line.
msgs() { python3 -c 'import json, sys
for e in json.load(open(sys.argv[1]))["events"]:
    if sys.argv[2] in ("", e["host"]) and e["status"] == "ok" and e["action"].split(".")[-1] == "debug" and e["msg"]:
        print(e["msg"].strip())' "$OUT" "${1:-}"; }
# events: that run's results, one a line: host, status, action, handler
# (True or False), task name and message, separated by tabs.
events() { python3 -c 'import json, sys
for e in json.load(open(sys.argv[1]))["events"]:
    print("\t".join(str(e[k]).replace("\t", " ").replace("\n", " ") for k in ("host", "status", "action", "handler", "task", "msg")))' "$OUT"; }
# recap HOST KEY: a count from that run's recap (ok, changed, failures,
# unreachable, skipped, rescued, ignored).
recap() { python3 -c 'import json, sys
print(json.load(open(sys.argv[1]))["stats"].get(sys.argv[2], {}).get(sys.argv[3], -1))' "$OUT" "$1" "$2"; }
# clean: that run reached every node and nothing failed.
clean() { python3 -c 'import json, sys
s = json.load(open(sys.argv[1]))["stats"]
sys.exit(not (len(s) >= int(sys.argv[2]) and all(v["failures"] == 0 and v["unreachable"] == 0 for v in s.values())))' "$OUT" "$(nodes_names | wc -l)"; }

task 1 "disk.yml: a message where there's a disk vdc, \"Disk vdc does not exist\" elsewhere"
need "/home/greg/ansible/disk.yml exists" '[ -f /home/greg/ansible/disk.yml ]'
need "ansible-playbook disk.yml runs on every node without failures" 'play disk.yml && clean'
need "node1, which has vdc, prints one message, and not \"does not exist\"" '[ "$(msgs node1 | wc -l)" = 1 ] && ! msgs node1 | grep -q "does not exist"'
for n in node2 node3; do
	need "$n, which has no vdc, prints only \"Disk vdc does not exist\"" "[ \"\$(msgs $n)\" = 'Disk vdc does not exist' ]"
done

task 2 "mariadb-server only on dbservers hosts with at least 2 GiB, from a play on all"
need "/home/greg/ansible/mariadb.yml exists" '[ -f /home/greg/ansible/mariadb.yml ]'
need "mariadb.yml's play targets all three nodes" 'ans ansible-playbook --list-hosts mariadb.yml | grep -q "hosts (3)"'
need "mariadb-server is installed on node2 (dbservers, 4 GiB)" 'in_node node2 rpm -q mariadb-server'
need "mariadb-server is not installed on node3 (dbservers, but 1 GiB)" '! in_node node3 rpm -q mariadb-server'
need "mariadb-server is not installed on node1 (webservers)" '! in_node node1 rpm -q mariadb-server'

task 3 "upgrade.yml prints Upgrading only with -e upgrade=true"
need "/home/greg/ansible/upgrade.yml exists" '[ -f /home/greg/ansible/upgrade.yml ]'
need "with -e upgrade=true it runs cleanly and prints Upgrading" 'play upgrade.yml -e upgrade=true && clean && msgs | grep -q Upgrading'
need "with -e upgrade=false it runs cleanly and doesn't" 'play upgrade.yml -e upgrade=false && clean && ! msgs | grep -q Upgrading'
need "without -e it runs cleanly and doesn't" 'play upgrade.yml && clean && ! msgs | grep -q Upgrading'
rm -f "$OUT"
