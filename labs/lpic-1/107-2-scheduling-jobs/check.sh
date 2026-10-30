SINCE=$(state_get since)
H=$(getent passwd alice | cut -d: -f6)
# cron_ran: cron logged a job of alice's since setup, in the journal or a
# log file.
cron_ran() {
	local f n
	journalctl -q --since "$SINCE" --no-pager 2>/dev/null | grep -q "(alice) CMD" && return 0
	for f in /var/log/cron /var/log/syslog; do
		[ -f "$f" ] || continue
		n=$(state_get "size$(echo "$f" | tr / _)"); n=${n:-0}
		[ "$(stat -c %s "$f")" -ge "$n" ] || n=0
		tail -c +$((n + 1)) "$f" | grep -q "(alice) CMD" && return 0
	done
	return 1
}
lines() { wc -l <"$1" 2>/dev/null || echo 0; }

task 1 "A two-minute crontab entry for alice that ran, then was removed"
need "$H/date.log has a line" '[ -s "$H/date.log" ]'
need "cron ran a job as alice" cron_ran
need "alice's crontab no longer has the entry" '! cat /var/spool/cron/alice /var/spool/cron/crontabs/alice 2>/dev/null | grep -Ev "^[[:space:]]*#" | grep -q date'

task 2 "An at job that ran, and another removed with atrm"
need "atd is running" active atd
need "atd starts at boot" enabled atd
need "/var/tmp/at-first has first" 'grep -qx first /var/tmp/at-first'
need "/root/lab-answers/2 holds a job number" '[[ "$(answer 2)" =~ ^[0-9]+$ ]]'
need "that job is no longer queued" '! atq | awk "{print \$1}" | grep -qx "$(answer 2)"'
need "that job was created" '
	seq=$(cat /var/spool/at/.SEQ /var/spool/cron/atjobs/.SEQ 2>/dev/null | head -n1)
	[ -n "$seq" ] && [ "$(answer 2)" -ge 1 ] && [ "$(answer 2)" -le "$((16#$seq))" ]'
need "the second job didn't run (/var/tmp/at-second doesn't exist)" '[ ! -e /var/tmp/at-second ]'

task 3 "alice in cron.deny, then a cron.allow without her"
need "/etc/cron.deny lists alice" 'grep -qx alice /etc/cron.deny'
need "/etc/cron.allow exists" '[ -f /etc/cron.allow ]'
need "/etc/cron.allow doesn't list alice" '! grep -qx alice /etc/cron.allow'
need "alice is refused by crontab" 'runuser -u alice -- crontab -l 2>&1 | grep -qi "not allowed"'

task 4 "datelog.timer runs datelog.service as alice every two minutes"
need "datelog.service exists" 'systemctl cat datelog.service'
need "datelog.timer is enabled" enabled datelog.timer
need "datelog.timer is active" active datelog.timer
need "datelog.timer runs every two minutes" 'systemctl show -p TimersCalendar --value datelog.timer | grep -q "OnCalendar=\*-\*-\* \*:00/2:00 "'
need "datelog.timer starts datelog.service" '[ "$(systemctl show -p Unit --value datelog.timer)" = datelog.service ]'
need "datelog.service runs as alice" '[ "$(systemctl show -p User --value datelog.service)" = alice ]'
need "running datelog.service appends a line to $H/date.log" '
	n=$(lines "$H/date.log"); systemctl start datelog.service; sleep 1
	[ "$(lines "$H/date.log")" -gt "$n" ]'
