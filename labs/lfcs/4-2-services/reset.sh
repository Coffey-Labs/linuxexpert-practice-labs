systemctl disable --now heartbeat.service ticker.service 2>/dev/null
# The scripts heartbeat.service ran, if they're lab-looking files.
for w in $(systemctl show -p ExecStart --value heartbeat 2>/dev/null | sed -n 's/.*argv\[\]=\([^;]*\);.*/\1/p'); do
	case $w in /usr/local/bin/* | /opt/heartbeat/*) [ -f "$w" ] && rm -f "$w" ;; esac
done
rm -rf /etc/systemd/system/heartbeat.service /etc/systemd/system/heartbeat.service.d /etc/default/heartbeat /opt/heartbeat
rm -rf /etc/systemd/system/ticker.service /etc/systemd/system/ticker.service.d /usr/local/bin/ticker
for u in chrony chronyd; do
	d=/etc/systemd/system/$u.service.d
	[ -d "$d" ] || continue
	grep -l '^[[:space:]]*Restart=' "$d"/*.conf 2>/dev/null | xargs -r rm -f
	rmdir "$d" 2>/dev/null
done
systemctl daemon-reload
systemctl reset-failed heartbeat.service ticker.service 2>/dev/null
for u in heartbeat ticker tickerd; do userdel -r "$u" 2>/dev/null; done
true
