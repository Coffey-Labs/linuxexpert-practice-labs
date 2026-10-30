boots() { journalctl -q --list-boots --no-pager 2>/dev/null | grep -c .; }
init_ok() {
	local l1 l2
	l1=$(sed -n 1p /root/lab-answers/3 2>/dev/null | tr -d '[:space:]')
	l2=$(sed -n 2p /root/lab-answers/3 2>/dev/null | tr -d '[:space:]')
	[ "$l1" = "$(ps -p 1 -o comm= | tr -d ' ')" ] || return 1
	[ -n "$l2" ] && case $(readlink -f /sbin/init) in *"${l2#..}") return 0 ;; esac
	[ "$l2" = "$(readlink /sbin/init)" ]
}

task 1 "Booted once into rescue.target from the GRUB menu" self

task 2 "The journal kept on disk across reboots"
need "/var/log/journal exists" '[ -d /var/log/journal ]'
need "the journal is written to /var/log/journal" 'ls /var/log/journal/*/system.journal'
need "the VM has been rebooted since the lab started" '[ "$(cat /proc/sys/kernel/random/boot_id)" != "$(state_get boot-id)" ]'
need "journalctl --list-boots shows more than one boot" '[ "$(boots)" -ge 2 ]'

task 3 "PID 1 and /sbin/init identified"
need "line 1 of /root/lab-answers/3 is PID 1's name, line 2 what /sbin/init points to" init_ok
