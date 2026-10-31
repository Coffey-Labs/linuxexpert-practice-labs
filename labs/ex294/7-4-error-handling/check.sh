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

OUT2=$LAB_STATE/check.txt
# rescued HOST: in that run, a service task failed on HOST and a debug task
# then printed its name and message.
rescued() { events | awk -F'\t' -v h="$1" '
	$1 == h && $2 == "failed" && $3 ~ /(^|\.)(service|systemd|systemd_service)$/ { t[$5] = $6 }
	$1 == h && $2 == "ok" && $3 ~ /(^|\.)debug$/ { for (n in t) if (index($6, n) && index($6, t[n])) ok = 1 }
	END { exit !ok }'; }
# ran HOST: a command or shell task ran on HOST in that run.
ran() { events | awk -F'\t' -v h="$1" '$1 == h && $2 == "ok" && $3 ~ /(^|\.)(command|shell)$/ { ok = 1 } END { exit !ok }'; }

task 1 "block.yml: start a missing service, rescue with its name and message, log in always"
need "/home/greg/ansible/block.yml exists" '[ -f /home/greg/ansible/block.yml ]'
need "ansible-playbook block.yml reaches every node with failed=0" 'play block.yml && clean'
for n in $(nodes_names); do
	need "$n shows rescued=1" '[ "$(recap '$n' rescued)" -ge 1 ]'
	need "on $n, a service task failed and the rescue printed its name and message" "rescued $n"
	need "/var/log/block.log on $n has a line" "in_node $n 'grep -q . /var/log/block.log'"
done

task 2 "grep.yml: no match is fine, a missing file fails"
need "/home/greg/ansible/grep.yml exists" '[ -f /home/greg/ansible/grep.yml ]'
need "ansible-playbook grep.yml runs grep on every node with failed=0" 'play grep.yml && clean && ran node1 && ran node2'
need "with -e grep_file=/etc/no-such-file it fails on every node" 'play grep.yml -e grep_file=/etc/no-such-file && [ "$(recap node1 failures)" = 1 ] && [ "$(recap node2 failures)" = 1 ]'

task 3 "stop.yml: when node1 fails, the play stops on every host"
need "/home/greg/ansible/stop.yml exists" '[ -f /home/greg/ansible/stop.yml ]'
need "stop.yml has a task after the failing one" '[ "$(ans ansible-playbook --list-tasks stop.yml | grep -v "^ *play #" | grep -c "TAGS: ")" -ge 2 ]'
need "the run shows NO MORE HOSTS LEFT" 'ans ansible-playbook stop.yml >"$OUT2"; grep -q "NO MORE HOSTS LEFT" "$OUT2"'
need "node1 failed and node2 didn't" 'grep -Eq "^node1 +: .*failed=1" "$OUT2" && grep -Eq "^node2 +: .*failed=0" "$OUT2"'
need "no task ran on any host after that" '! sed -n "/NO MORE HOSTS LEFT/,/PLAY RECAP/p" "$OUT2" | grep -Eq "^(ok|changed|fatal|failed): "'
rm -f "$OUT" "$OUT2"
