START=$(state_get start)
cronline='^[[:space:]]*30[[:space:]]+14[[:space:]]+\*[[:space:]]+\*[[:space:]]+(1-5|mon-fri|Mon-Fri|MON-FRI|1,2,3,4,5)[[:space:]]+/usr/bin/logger[[:space:]]+hello[[:space:]]*$'

# Timers made since the lab started, enabled and running, as NAME.timer.
new_timers() {
	local f
	for f in /etc/systemd/system/*.timer; do
		[ -f "$f" ] || continue
		grep -qxF "$f" "$LAB_STATE/timers-before" 2>/dev/null && continue
		f=${f##*/}
		enabled "$f" && active "$f" && echo "$f"
	done
}
every15() {
	systemctl show -p TimersCalendar -p TimersMonotonic "$1" |
		grep -Eq 'OnCalendar=\*-\*-\* \*:00/15:00|OnCalendar=\*-\*-\* \*:00,15,30,45:00|OnUnit(Active|Inactive)USec=15min ;'
}
# Seconds until the timer's next run.
next_in() {
	systemctl list-timers --all -o json 2>/dev/null | python3 -c '
import json, sys, time
for t in json.load(sys.stdin):
    if t["unit"] == sys.argv[1] and t.get("next"):
        print(int(t["next"] / 1e6 - time.time())); break' "$1"
}
svc_of() { systemctl show -p Unit --value "$1"; }
ran() { journalctl -q -u "$(svc_of "$1")" --since "@$START" 2>/dev/null | grep -q .; }
# The first new timer that passes every test in turn.
pick() {
	local t
	for t in $(new_timers); do
		every15 "$t" || continue
		[ "$1" = interval ] && { echo "$t"; return; }
		n=$(next_in "$t"); [ -n "$n" ] && [ "$n" -le 905 ] || continue
		[ "$1" = next ] && { echo "$t"; return; }
		ran "$t" && { echo "$t"; return; }
	done
	return 1
}

task 1 "alice's crontab runs /usr/bin/logger hello at 14:30 on weekdays"
need "crond is running" active crond
need "alice has a crontab" 'crontab -u alice -l'
need "alice's crontab has 30 14 * * 1-5 /usr/bin/logger hello" 'crontab -u alice -l | grep -Eq "$cronline"'

task 2 "A timer runs a script every 15 minutes, also after a reboot"
need "a new timer in /etc/systemd/system is enabled and active" '[ -n "$(new_timers)" ]'
need "the timer runs every 15 minutes" 'pick interval'
need "the timer's next run is at most 15 minutes away" 'pick next'
need "its service has run since the lab started (journalctl -u)" 'pick ran'
need "the service runs a script that exists" 'svc=$(svc_of "$(pick ran)"); p=$(systemctl show -p ExecStart --value "$svc" | sed -n "s/.*path=\([^ ;]*\).*/\1/p" | head -n1); [ -x "$p" ]'

task 3 "/tmp/at-ran made by an at job; a second job canceled"
need "atd is running" active atd
need "/tmp/at-ran exists" test -e /tmp/at-ran
need "/tmp/at-ran was made after the lab started" '[ "$(stat -c %Y /tmp/at-ran)" -ge "$START" ]'
need "at least two at jobs were made since the lab started" '
	seq=$(head -n1 /var/spool/at/.SEQ 2>/dev/null)
	[ -n "$seq" ] && [ $((16#$seq - $(state_get at-seq))) -ge 2 ]'
need "no at job is left in the queue (atq is empty)" '[ -z "$(atq 2>/dev/null)" ]'
