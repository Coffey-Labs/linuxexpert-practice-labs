for u in report-builder message-broker cache-prime; do
	systemctl disable --now --quiet "$u.service" 2>/dev/null
	rm -rf "/etc/systemd/system/$u.service" "/etc/systemd/system/$u.service.d"
done
systemctl daemon-reload
rm -f /usr/local/lib/le-lab/report-builder /usr/local/lib/le-lab/msgbroker.py
rmdir /usr/local/lib/le-lab 2>/dev/null
systemctl disable --quiet --now sysstat.service sysstat-collect.timer sysstat-summary.timer 2>/dev/null
is_debian && sed -i 's/^ENABLED=.*/ENABLED="false"/' /etc/default/sysstat 2>/dev/null
true
