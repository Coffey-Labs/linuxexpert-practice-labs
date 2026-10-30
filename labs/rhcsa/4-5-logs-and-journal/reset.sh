rm -f /root/ssh-errors.txt /etc/systemd/journald.conf.d/00-le-lab.conf
for f in /etc/systemd/journald.conf.d/*; do
	[ -e "$f" ] || continue
	grep -qxF "${f##*/}" "$LAB_STATE/journald-d" 2>/dev/null || rm -f "$f"
done
rmdir /etc/systemd/journald.conf.d 2>/dev/null
if [ -f "$LAB_STATE/journald.conf" ]; then
	cp -a "$LAB_STATE/journald.conf" /etc/systemd/journald.conf
else
	rm -f /etc/systemd/journald.conf
fi
[ -n "$(state_get had-journal-dir)" ] || rm -rf /var/log/journal
systemctl restart systemd-journald
systemctl restart rsyslog
true
