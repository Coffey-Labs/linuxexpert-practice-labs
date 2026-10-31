if [ -f /etc/systemd/system/le-lab-l2.service ]; then
	systemctl disable --quiet le-lab-l2.service 2>/dev/null
	rm -f /etc/systemd/system/le-lab-l2.service
	systemctl daemon-reload
fi
if [ -n "$(state_get had-arping)" ]; then
	pkg_installed iputils-arping || DEBIAN_FRONTEND=noninteractive apt-get -y -qq install iputils-arping >/dev/null 2>&1
elif pkg_installed iputils-arping; then
	DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge iputils-arping >/dev/null 2>&1
fi
true
