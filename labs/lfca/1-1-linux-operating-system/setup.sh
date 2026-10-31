pkg_installed tree && state_set had-tree 1
# The process for task 3, as if started with "sleep 6000 &".
systemctl stop le-lab-sleep.service 2>/dev/null || true
systemctl reset-failed le-lab-sleep.service 2>/dev/null || true
systemd-run --quiet --unit=le-lab-sleep --description="Practice lab sleep" /usr/bin/sleep 6000
for i in 1 2 3 4 5; do
	pid=$(systemctl show -p MainPID --value le-lab-sleep.service)
	[ "${pid:-0}" != 0 ] && break
	sleep 1
done
state_set sleep-pid "$pid"
