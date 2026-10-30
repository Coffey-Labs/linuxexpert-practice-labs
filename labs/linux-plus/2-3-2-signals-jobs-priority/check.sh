yes_pid() { systemctl show -p MainPID --value le-lab-yes.service; }

task 1 "sleep 1000 stopped, sleep 1001 still running"
need "no process runs sleep 1000" '! pgrep -fx "sleep 1000"'
need "sleep 1001 is still running" 'pgrep -fx "sleep 1001"'

task 2 "alice's yes runs at nice 19"
need "alice's yes process is still running" '[ "$(yes_pid)" -gt 0 ] && [ "$(ps -o user= -p "$(yes_pid)")" = alice ]'
need "it runs at nice 19" '[ "$(ps -o ni= -p "$(yes_pid)" | tr -d " ")" = 19 ]'
