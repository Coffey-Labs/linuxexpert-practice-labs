# The part of a log file written since the lab started.
since_start() {
	local t; t=$(state_get token)
	if grep -q "$t" "$1"; then
		sed -n "/$t/,\$p" "$1"
	elif [ "$(stat -c %W "$1")" -gt "$(state_get since)" ]; then
		cat "$1"    # rotated since the lab started
	fi
}
BOOT=$(tr -d - </proc/sys/kernel/random/boot_id)
# Warning-level syslog messages since the lab started that didn't come from
# a service (as logger sends them from a shell), one per line.
warning_msgs() {
	journalctl -q --since "@$(state_get since)" -p warning..warning _TRANSPORT=syslog -o json 2>/dev/null |
		python3 -I -c '
import json, sys
for line in sys.stdin:
    e = json.loads(line)
    unit = e.get("_SYSTEMD_UNIT") or ""
    m = e.get("MESSAGE")
    if isinstance(m, str) and m and not unit.endswith(".service"):
        print(m)'
}
logged_too() {
	local m
	while read -r m; do
		since_start /var/log/messages | grep -qF -- "$m" && return 0
	done < <(warning_msgs)
	return 1
}

task 1 "A persistent journal, with the previous boot in it"
need "the journal of this boot is stored in /var/log/journal" '[ -d /var/log/journal ] && journalctl -q -D /var/log/journal _BOOT_ID=$BOOT -n1 | grep -q .'
need "you rebooted since the lab started" '[ "$(cat /proc/sys/kernel/random/boot_id)" != "$(state_get boot-id)" ]'
need "journalctl --list-boots lists at least two boots" '[ "$(journalctl -q --list-boots 2>/dev/null | grep -Ec "[0-9a-f]{32}")" -ge 2 ]'
need "journalctl -b -1 shows the previous boot" 'journalctl -q -b -1 -n1 | grep -q .'

task 2 "sshd errors of the last hour in /root/ssh-errors.txt"
need "/root/ssh-errors.txt exists and isn't empty" '[ -s /root/ssh-errors.txt ]'
need "it holds sshd messages or -- No entries --" 'grep -q "No entries" /root/ssh-errors.txt || ! grep -v "^--" /root/ssh-errors.txt | grep -v sshd | grep -q .'

task 3 "A warning sent with logger, in the journal and /var/log/messages"
need "the journal has a warning-level message sent with logger" '[ -n "$(warning_msgs)" ]'
need "/var/log/messages has it too" logged_too

task 4 "A failed su - by a normal user in /var/log/secure"
need "/var/log/secure shows a su authentication failure for root by a normal user" 'since_start /var/log/secure | grep -E "su(\[[0-9]+\])?: pam_unix\(su(-l)?:auth\): authentication failure" | grep "user=root" | grep -Eq " uid=[1-9][0-9]{3,} "'
