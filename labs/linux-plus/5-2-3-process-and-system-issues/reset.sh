pid=$(state_get worker-pid)
[ -n "$pid" ] && kill -CONT "$pid" 2>/dev/null
systemctl stop queue-worker.service 2>/dev/null
rm -f /etc/systemd/system/queue-worker.service /usr/local/lib/le-lab/queue-worker
rm -rf /var/lib/queue-worker
rmdir /usr/local/lib/le-lab 2>/dev/null
systemctl daemon-reload
crontab -r -u ops 2>/dev/null
rm -f /usr/local/sbin/labtool
if [ -n "$(state_get made-journal)" ]; then
	journalctl --relinquish-var 2>/dev/null
	rm -rf /var/log/journal
	systemctl restart systemd-journald
fi
true
