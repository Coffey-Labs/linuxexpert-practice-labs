command -v auditctl >/dev/null && auditctl -W /etc/hosts -p wa -k hosts-change >/dev/null 2>&1
sed -i '/^# test$/d' /etc/hosts
rm -rf /var/log/labapp /etc/logrotate.d/labapp
# The journal as it was.
journalctl --relinquish-var 2>/dev/null
rm -rf /var/log/journal
if [ -d "$LAB_STATE/journal.saved" ]; then
	mv "$LAB_STATE/journal.saved" /var/log/journal
	journalctl --flush
fi
true
