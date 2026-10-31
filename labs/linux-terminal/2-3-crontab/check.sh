H=$(state_get home)
CT=$(crontab -l -u student 2>/dev/null | grep -Ev '^[[:space:]]*(#|$)')
# The cron.d file with the cleanup job.
CD=$(grep -lE '^[[:space:]]*15[[:space:]]+0?3[[:space:]]+1[[:space:]]+\*[[:space:]]+\*[[:space:]]+root[[:space:]]+/usr/local/bin/cleanup[[:space:]]*$' /etc/cron.d/* 2>/dev/null | head -n1)
refused() { runuser -u "$1" -- crontab -l 2>&1 | grep -q "not allowed"; }
others_ok() {
	local u
	refused root && return 1
	for u in $(awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd); do
		[ "$u" = alice ] && continue
		refused "$u" && return 1
	done
	return 0
}
boot_log() {
	local i
	for i in $(seq 15); do
		grep -qx booted "$H/boot.log" 2>/dev/null && return 0
		sleep 1
	done
	return 1
}

task 1 "student's crontab: date to ~/ticks.log every two minutes, booted to ~/boot.log at boot"
need "student's crontab has a line that appends date to ~/ticks.log every two minutes" \
	'grep -E "^(\*/2|0-59/2|0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58)[[:space:]]+\*[[:space:]]+\*[[:space:]]+\*[[:space:]]+\*[[:space:]]" <<<"$CT" | grep "date" | grep -q ">>.*ticks\.log"'
need "student's crontab has an @reboot line that writes booted to ~/boot.log" 'grep -E "^@reboot[[:space:]]" <<<"$CT" | grep -q "boot\.log"'
need "$H/ticks.log has a date in it" 'grep -Eq "20[0-9][0-9]" "$H/ticks.log"'
need "$H/boot.log contains booted (after a reboot)" boot_log

task 2 "/etc/cron.d job: /usr/local/bin/cleanup as root at 3:15 on the 1st"
need "a file in /etc/cron.d holds 15 3 1 * * root /usr/local/bin/cleanup" '[ -n "$CD" ]'
need "its name has no dot in it" '[[ "${CD##*/}" =~ ^[A-Za-z0-9_-]+$ ]]'
need "it's owned by root and not writable by group or others" '[ "$(stat -c %U "$CD")" = root ] && [ -z "$(find "$CD" -perm /022)" ]'

task 3 "alice can't use crontab; everyone else still can"
need "alice's crontab -l says she isn't allowed" 'refused alice'
need "student's crontab -l still works" '! refused student'
need "no other user (or root) is refused" others_ok
