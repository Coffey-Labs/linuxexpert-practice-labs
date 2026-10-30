# The part of /var/log/messages written since the lab started.
since_start() {
	local t; t=$(state_get token)
	if grep -q "$t" /var/log/messages; then
		sed -n "/$t/,\$p" /var/log/messages
	elif [ "$(stat -c %W /var/log/messages)" -gt "$(state_get since)" ]; then
		cat /var/log/messages    # rotated since the lab started
	fi
}

task 1 "Booted into rescue.target once" self

task 2 "The bad fstab line no longer stops the boot"
need "fstab's le-nodisk line no longer stops the boot" '
	! findmnt --fstab -n -S LABEL=le-nodisk >/dev/null ||
	findmnt --fstab -n -o OPTIONS -S LABEL=le-nodisk | grep -qw nofail'
need "findmnt --verify reports no errors" 'findmnt --verify 2>&1 | grep -Eq "(^| )0 errors|no errors"'
need "the system reached multi-user.target" 'systemctl is-active --quiet multi-user.target'
need "the system isn't in emergency or rescue mode" '! systemctl is-active --quiet emergency.target && ! systemctl is-active --quiet rescue.target'
need "systemctl --failed lists no mount units" '! systemctl --failed --no-legend --plain | grep -q "\.mount"'

task 3 "A reboot scheduled with a message, then cancelled"
need "no shutdown is scheduled now" '[ ! -e /run/systemd/shutdown/scheduled ]'
need "/var/log/messages shows a scheduled shutdown was cancelled" 'since_start | grep -q "System shutdown has been cancelled"'

task 4 "Switched to the text target and back on a desktop VM" self
