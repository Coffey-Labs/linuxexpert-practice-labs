cronline='^[[:space:]]*30[[:space:]]+(2|02)[[:space:]]+\*[[:space:]]+\*[[:space:]]+(1-5|mon-fri|Mon-Fri|MON-FRI|1,2,3,4,5)[[:space:]]+'

task 1 "alice's crontab runs the date command at 02:30 on weekdays"
need "alice has a crontab" 'crontab -u alice -l'
need "alice's crontab has 30 2 * * 1-5 /usr/bin/date >> /tmp/alice-date.log" 'crontab -u alice -l | grep -E "$cronline" | grep -Eq "/usr/bin/date[[:space:]]*>>[[:space:]]*/tmp/alice-date\.log"'

task 2 "An at job queued, its number noted, then cancelled"
need "atd is running" active atd
need "atd starts at boot" enabled atd
need "/root/lab-answers/2 holds a job number" '[[ "$(answer 2)" =~ ^[0-9]+$ ]]'
need "that job was created" '
	seq=$(cat /var/spool/at/.SEQ /var/spool/cron/atjobs/.SEQ 2>/dev/null | head -n1)
	[ -n "$seq" ] && [ "$(answer 2)" -ge 1 ] && [ "$(answer 2)" -le "$((16#$seq))" ]'
need "that job is no longer queued" '! atq | awk "{print \$1}" | grep -qx "$(answer 2)"'
need "it was cancelled, not run (/tmp/at-test has no hello)" '! grep -qs hello /tmp/at-test'

task 3 "cleanup.timer runs cleanup.service daily at 03:00, catching up"
need "cleanup.service exists" 'systemctl cat cleanup.service'
need "cleanup.timer is enabled" enabled cleanup.timer
need "cleanup.timer is active" active cleanup.timer
need "cleanup.timer runs at 03:00 every day" 'systemctl show -p TimersCalendar --value cleanup.timer | grep -q "OnCalendar=\*-\*-\* 03:00:00 "'
need "cleanup.timer catches up after downtime" '[ "$(systemctl show -p Persistent --value cleanup.timer)" = yes ]'
need "cleanup.timer starts cleanup.service" '[ "$(systemctl show -p Unit --value cleanup.timer)" = cleanup.service ]'
need "cleanup.service deletes files in /tmp/scratch older than 7 days, and only those" '
	mkdir -p /tmp/scratch
	touch -d "10 days ago" /tmp/scratch/le-check-old
	touch /tmp/scratch/le-check-new
	systemctl start cleanup.service; sleep 1
	r=0; { [ ! -e /tmp/scratch/le-check-old ] && [ -e /tmp/scratch/le-check-new ]; } || r=1
	rm -f /tmp/scratch/le-check-old /tmp/scratch/le-check-new
	exit $r'

task 4 "bob can't use crontab; others still can"
need "bob is refused by crontab" 'runuser -u bob -- crontab -l 2>&1 | grep -qi "not allowed"'
need "alice can still use crontab" '! runuser -u alice -- crontab -l 2>&1 | grep -qi "not allowed"'
