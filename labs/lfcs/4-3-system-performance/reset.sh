for u in index-builder cache-warmup inventory-sync; do
	systemctl disable --now "$u.service" 2>/dev/null
	rm -rf "/etc/systemd/system/$u.service" "/etc/systemd/system/$u.service.d"
done
pkill -x stress-ng 2>/dev/null
systemctl daemon-reload
systemctl reset-failed 2>/dev/null
if is_rhel; then
	systemctl disable --quiet --now sysstat.service sysstat-collect.timer sysstat-summary.timer 2>/dev/null
else
	sed -i 's/^ENABLED=.*/ENABLED="false"/' /etc/default/sysstat 2>/dev/null
fi
if [ -n "$(state_get made-journal)" ]; then
	rm -rf /var/log/journal
	systemctl restart systemd-journald
fi
true
