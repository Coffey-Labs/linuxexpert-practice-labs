CHRONY=$(pick chronyd chrony)
hb_pid() { systemctl show -p MainPID --value heartbeat; }

# The value of INTERVAL in /etc/default/heartbeat, without quotes.
interval() {
	sed -n 's/^[[:space:]]*\(export[[:space:]]\{1,\}\)\{0,1\}INTERVAL=//p' /etc/default/heartbeat |
		tail -n1 | tr -d "\"'" | sed 's/[[:space:]]*$//'
}

# The running service got INTERVAL from the file.
hb_has_interval() {
	local v pid
	v=$(interval); pid=$(hb_pid)
	[ -n "$v" ] && [ "${pid:-0}" != 0 ] && tr '\0' '\n' <"/proc/$pid/environ" | grep -qxF "INTERVAL=$v"
}

# ExecStart, or a script it runs, mentions INTERVAL.
hb_uses_interval() {
	local argv w
	argv=$(systemctl show -p ExecStart --value heartbeat | sed -n 's/.*argv\[\]=\([^;]*\);.*/\1/p')
	case $argv in *INTERVAL*) return 0 ;; esac
	for w in $argv; do
		[ -f "$w" ] && grep -Iq INTERVAL "$w" && return 0
	done
	return 1
}

task 1 "Service heartbeat as system user heartbeat, restarting after 5 seconds"
need "user heartbeat exists" id heartbeat
need "heartbeat is a system user (UID below UID_MIN)" '[ "$(id -u heartbeat)" -lt "$(awk "\$1 == \"UID_MIN\" {print \$2}" /etc/login.defs)" ]'
need "heartbeat.service is enabled" enabled heartbeat.service
need "heartbeat.service is running" active heartbeat.service
need "it runs as user heartbeat" '[ "$(ps -o uid= -p "$(hb_pid)" | tr -d " ")" = "$(id -u heartbeat)" ]'
need "it restarts on failure" 'systemctl show -p Restart --value heartbeat | grep -Eqx "on-failure|always"'
need "it waits 5 seconds before restarting" '[ "$(systemctl show -p RestartUSec --value heartbeat)" = 5s ]'

task 2 "heartbeat reads INTERVAL from /etc/default/heartbeat"
need "/etc/default/heartbeat sets INTERVAL" '[ -n "$(interval)" ]'
need "heartbeat.service reads /etc/default/heartbeat" 'systemctl show -p EnvironmentFiles --value heartbeat | grep -q /etc/default/heartbeat'
need "the running service has the INTERVAL from the file (restart it after changes)" hb_has_interval
need "the service or its script uses INTERVAL" hb_uses_interval

task 3 "chrony restarts always, through a drop-in"
need "chrony is installed" pkg_installed chrony
need "$CHRONY.service has Restart=always" '[ "$(systemctl show -p Restart --value "$CHRONY")" = always ]'
need "the setting is in a drop-in under /etc/systemd/system/$CHRONY.service.d/" 'systemctl show -p DropInPaths --value "$CHRONY" | tr " " "\n" | grep "^/etc/systemd/system/" | xargs -r grep -hEq "^[[:space:]]*Restart=always"'
need "the packaged unit file is still the one in use" 'systemctl show -p FragmentPath --value "$CHRONY" | grep -Eq "^/(usr/)?lib/systemd/"'

task 4 "ticker.service fixed"
need "ticker.service is running" active ticker.service
need "ticker.service is enabled" enabled ticker.service
need "systemd-analyze verify ticker.service prints nothing" '[ -z "$(systemd-analyze verify ticker.service 2>&1)" ]'
