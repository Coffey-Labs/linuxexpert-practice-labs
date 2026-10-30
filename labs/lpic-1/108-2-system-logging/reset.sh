# journald as it was.
if [ -f "$LAB_STATE/journald.conf" ]; then cp -a "$LAB_STATE/journald.conf" /etc/systemd/journald.conf; fi
for f in /etc/systemd/journald.conf.d/*; do
	[ -e "$f" ] || continue
	grep -qxF "${f##*/}" "$LAB_STATE/journald-d" 2>/dev/null || rm -f "$f"
done
journalctl --relinquish-var 2>/dev/null
if [ -n "$(state_get moved-journal)" ]; then
	if [ -d /var/log/journal.le-lab ]; then
		rm -rf /var/log/journal
		mv /var/log/journal.le-lab /var/log/journal
	fi
else
	rm -rf /var/log/journal
fi
systemctl restart systemd-journald
journalctl --flush 2>/dev/null
# rsyslog as it was.
if [ -f "$LAB_STATE/rsyslog.conf" ]; then cp -a "$LAB_STATE/rsyslog.conf" /etc/rsyslog.conf; fi
for f in /etc/rsyslog.d/*; do
	[ -e "$f" ] || continue
	grep -qxF "${f##*/}" "$LAB_STATE/rsyslog-d" 2>/dev/null || rm -f "$f"
done
rm -f /var/log/local3.log
systemctl is-active --quiet rsyslog && systemctl restart rsyslog
rm -rf /var/log/lrtest /etc/logrotate.d/lrtest
true
