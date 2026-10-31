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

# handlers HOST: how many handlers ran on HOST in that run.
handlers() { events | awk -F'\t' -v h="$1" '$1 == h && $2 == "ok" && $4 == "True"' | wc -l; }
# header HOST: the Server header httpd on HOST sends.
header() { curl -sI -m 10 "http://$1/" | tr -d '\r' | sed -n 's/^Server: //Ip'; }
C=/etc/httpd/conf/httpd.conf

task 1 "web.yml sets ServerTokens Prod and restarts httpd only on a change"
need "/home/greg/ansible/web.yml exists" '[ -f /home/greg/ansible/web.yml ]'
for n in $(nodes_names); do
	need "$n's httpd.conf says ServerTokens Prod" "in_node $n grep -qx 'ServerTokens Prod' $C"
	need "httpd on $n was restarted since: its Server header is just Apache" '[ "$(header '$n')" = Apache ]'
done
need "a second run of web.yml has changed=0 and runs no handler" 'play web.yml && clean && for n in $(nodes_names); do [ "$(recap $n changed)" = 0 ] && [ "$(handlers $n)" = 0 ] || exit 1; done'

task 2 "listen.yml: one listen topic runs two handlers"
need "/home/greg/ansible/listen.yml exists" '[ -f /home/greg/ansible/listen.yml ]'
need "its handlers use listen" 'grep -Eq "^[[:space:]]*listen:" /home/greg/ansible/listen.yml'
need "with KeepAlive On taken out of httpd.conf, listen.yml runs cleanly" 'for n in $(nodes_names); do in_node $n "sed -i /^KeepAlive/d $C"; done; play listen.yml && clean'
for n in $(nodes_names); do
	need "two handlers ran on $n" '[ "$(handlers '$n')" -ge 2 ]'
	need "$n's httpd.conf says KeepAlive On again" "in_node $n grep -qx 'KeepAlive On' $C"
done

task 3 "force.yml: a later task fails, and the handler runs anyway"
need "/home/greg/ansible/force.yml exists" '[ -f /home/greg/ansible/force.yml ]'
need "with Timeout 120 taken out of httpd.conf, force.yml fails a task on every node" 'for n in $(nodes_names); do in_node $n "sed -i /^Timeout/d $C"; done; play force.yml; for n in $(nodes_names); do [ "$(recap $n failures)" -ge 1 ] || exit 1; done'
for n in $(nodes_names); do
	need "the handler ran on $n all the same" '[ "$(handlers '$n')" -ge 1 ]'
	need "$n's httpd.conf says Timeout 120 again" "in_node $n grep -qx 'Timeout 120' $C"
done
rm -f "$OUT"
