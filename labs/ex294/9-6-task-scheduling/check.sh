nodes_wait 60 || true
# The /etc/cron.d line task 2 asks for: 02:00 on Sundays, as root, with /etc.
JOB='^0 +2 +\* +\* +(0|7|[Ss][Uu][Nn]) +root +.*/etc'

task 1 "logger \"EX294 in progress\" every 2 minutes for student on the web servers"
need "student's crontab on node1 runs logger \"EX294 in progress\" every 2 minutes" "in_node node1 crontab -l -u student | grep -Eq '^\*/2 +\* +\* +\* +\* +(/usr/bin/)?logger .?EX294 in progress'"
need "crond is running on node1" 'in_node node1 systemctl is-active --quiet crond'

task 2 "A Sunday 02:00 /etc backup in /etc/cron.d/backup, then removed from the web servers"
need "/etc/cron.d/backup on node2 archives /etc at 02:00 on Sundays, as root" "in_node node2 cat /etc/cron.d/backup | grep -Eq '$JOB'"
need "the job is gone from node1's /etc/cron.d/backup" "! in_node node1 cat /etc/cron.d/backup 2>/dev/null | grep -Eq '$JOB'"

task 3 "A daily cleanup.timer on the database servers"
need "cleanup.timer is enabled on node2" "[ \"\$(in_node node2 systemctl is-enabled cleanup.timer)\" = enabled ]"
need "cleanup.timer is active on node2" 'in_node node2 systemctl is-active --quiet cleanup.timer'
need "cleanup.timer runs every day (OnCalendar)" "in_node node2 systemctl show -P TimersCalendar cleanup.timer | grep -Eq 'OnCalendar=\*-\*-\* [0-9]'"
need "systemctl list-timers on node2 shows a next run for cleanup.timer" "in_node node2 systemctl list-timers --no-legend cleanup.timer | grep -q cleanup.timer && ! in_node node2 systemctl list-timers --no-legend cleanup.timer | grep -q '^-'"
need "the unit it starts exists" "u=\$(in_node node2 systemctl show -P Triggers cleanup.timer) && [ -n \"\$u\" ] && in_node node2 systemctl cat \"\$u\""
