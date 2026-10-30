for u in le-lab-app8080 le-lab-app9000; do
	systemctl disable --now --quiet "$u.service" 2>/dev/null
	rm -f "/etc/systemd/system/$u.service"
done
systemctl daemon-reload
rm -rf /srv/le-app /usr/local/lib/le-lab/httpd.py
rmdir /usr/local/lib/le-lab 2>/dev/null

if is_rhel; then
	if [ -f "$LAB_STATE/firewalld.tar" ]; then
		rm -rf /etc/firewalld
		tar -C /etc -xf "$LAB_STATE/firewalld.tar"
		command -v restorecon >/dev/null && restorecon -R /etc/firewalld
	fi
	if [ -n "$(state_get firewalld-was-active)" ]; then
		firewall-cmd -q --reload
	else
		systemctl disable --now --quiet firewalld
	fi
else
	[ -n "$(state_get ufw-was-active)" ] || ufw --force disable >/dev/null
	if [ -f "$LAB_STATE/ufw.tar" ]; then
		rm -rf /etc/ufw
		tar -C /etc -xf "$LAB_STATE/ufw.tar"
	fi
	[ -n "$(state_get ufw-was-active)" ] && ufw reload >/dev/null
fi
true
