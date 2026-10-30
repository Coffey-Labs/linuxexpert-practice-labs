for u in heartbeat webapp; do
	systemctl disable --now "$u.service" 2>/dev/null
	rm -rf "/etc/systemd/system/$u.service" "/etc/systemd/system/$u.service.d" "/etc/systemd/system.control/$u.service.d"
done
rm -f /usr/local/bin/heartbeat
rm -rf /srv/webapp
userdel webapp 2>/dev/null
# The open-file limit, wherever it went in /etc/systemd.
grep -rlEs '^[[:space:]]*(Default)?LimitNOFILE=' /etc/systemd/system/nginx.service.d /etc/systemd/system.conf.d \
	/etc/systemd/system.control/nginx.service.d 2>/dev/null | xargs -r rm -f
rm -f /etc/systemd/system/nginx.service
sed -i 's/^[[:space:]]*DefaultLimitNOFILE=65536/#&/' /etc/systemd/system.conf 2>/dev/null
rm -f $(grep -lEs '^[[:space:]]*alice[[:space:]]' /etc/security/limits.d/*.conf)
sed -i '/^[[:space:]]*alice[[:space:]]/d' /etc/security/limits.conf
systemctl daemon-reexec
systemctl restart nginx 2>/dev/null
systemctl reset-failed 2>/dev/null
true
