systemctl disable --now --quiet le-backend@8081 le-backend@8082 le-backend@8083 2>/dev/null
rm -f /etc/systemd/system/le-backend@.service /usr/local/lib/le-lab/backend.py
rmdir /usr/local/lib/le-lab 2>/dev/null
rm -rf /run/le-backend
systemctl daemon-reload

# nginx and HAProxy: as they were before the lab.
for p in nginx haproxy; do
	if [ -n "$(state_get had-$p)" ]; then
		rm -rf /etc/$p
		tar -C /etc -xf "$LAB_STATE/$p.tar"
		systemctl try-restart $p 2>/dev/null
	elif pkg_installed $p; then
		systemctl disable --now --quiet $p 2>/dev/null
		if is_rhel; then
			dnf -y -q remove $p >/dev/null
		else
			pkgs=$p
			[ $p = nginx ] && pkgs="nginx nginx-common"
			DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge $pkgs >/dev/null 2>&1
		fi
		rm -rf /etc/$p
	fi
done
v=$(state_get httpd-connect)
[ -n "$v" ] && setsebool -P httpd_can_network_connect "$v"
true
