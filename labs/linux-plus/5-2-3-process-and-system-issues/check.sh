START=$(state_get start)
PID=$(state_get worker-pid)
count() { cat /var/lib/queue-worker/count 2>/dev/null; }

task 1 "A segfault's core dump found"
need "coredumpctl lists a SIGSEGV since the lab started" 'coredumpctl list --no-legend --no-pager --since "@$START" 2>/dev/null | grep -Eq "SEGV|[[:space:]]11[[:space:]]"'

task 2 "The OOM killer acted in a limited scope"
need "the kernel log shows a process killed for memory since the lab started" 'journalctl -q -k --no-pager --since "@$START" | grep -Eqi "killed process|oom-kill"'

task 3 "queue-worker going again, without a restart"
need "/root/lab-answers/3 has the state code" 'answer 3 | grep -Eqw "t|stopped"'
need "the worker is the same process the lab started" '[ "$(systemctl show -p MainPID --value queue-worker.service)" = "$PID" ]'
need "it isn't stopped" '! ps -o stat= -p "$PID" | grep -q "^T"'
need "the count goes up" 'a=$(count); sleep 2.5; [ "$(count)" -gt "$a" ]'

task 4 "ops's cron job runs labtool"
need "ops's crontab still runs labtool every minute" 'crontab -l -u ops 2>/dev/null | grep -Eq "^\* \* \* \* \* .*labtool"'
need "the last line of /home/ops/labtool.log is labtool ran" '[ "$(tail -n1 /home/ops/labtool.log 2>/dev/null)" = "labtool ran" ]'
