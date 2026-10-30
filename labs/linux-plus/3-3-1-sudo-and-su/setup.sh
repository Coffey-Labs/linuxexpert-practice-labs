id sudotest >/dev/null 2>&1 && refuse "user sudotest already exists; remove it (userdel -r sudotest) and start again"
[ -e /etc/sudoers.d/sudotest ] && refuse "/etc/sudoers.d/sudotest already exists; remove it and start again"
state_set start "$(date +%s)"
# Task 2's evidence should survive a reboot.
if [ ! -d /var/log/journal ]; then
	mkdir -p /var/log/journal
	systemd-tmpfiles --create --prefix /var/log/journal
	journalctl --flush
	state_set made-journal 1
fi
true
