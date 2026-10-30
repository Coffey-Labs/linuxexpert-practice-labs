rm -f /etc/sudoers.d/sudotest
if id sudotest >/dev/null 2>&1; then
	pkill -KILL -u sudotest 2>/dev/null
	userdel -r sudotest 2>/dev/null
fi
if [ -n "$(state_get made-journal)" ]; then
	journalctl --relinquish-var 2>/dev/null
	rm -rf /var/log/journal
	systemctl restart systemd-journald
fi
true
