rm -f /usr/local/bin/testbash
systemctl disable --now --quiet labweb.service le-lab-backupd.service 2>/dev/null
rm -f /etc/systemd/system/labweb.service /etc/systemd/system/le-lab-backupd.service
systemctl daemon-reload
rm -f /usr/local/lib/le-lab/backupd.py
rmdir /usr/local/lib/le-lab 2>/dev/null
for f in /etc/sudoers.d/*; do
	[ -e "$f" ] || continue
	grep -qxF "${f##*/}" "$LAB_STATE/sudoers-d" 2>/dev/null || rm -f "$f"
done
for f in /etc/security/limits.d/*; do
	[ -e "$f" ] || continue
	grep -qxF "${f##*/}" "$LAB_STATE/limits-d" 2>/dev/null || rm -f "$f"
done
[ -f "$LAB_STATE/limits.conf" ] && cp -a "$LAB_STATE/limits.conf" /etc/security/limits.conf
if systemctl is-active --quiet firewalld; then
	firewall-cmd -q --zone=trusted --remove-interface=le-host 2>/dev/null
	firewall-cmd -q --permanent --zone=trusted --remove-interface=le-host 2>/dev/null
fi
[ -n "$(state_get ufw)" ] && ufw delete allow in on le-host >/dev/null 2>&1
users_remove
true
