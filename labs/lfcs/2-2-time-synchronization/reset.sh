tz=$(state_get tz)
[ -n "$tz" ] && timedatectl set-timezone "$tz"
if is_rhel; then
	if [ -f "$LAB_STATE/chrony.conf" ]; then
		cp -a "$LAB_STATE/chrony.conf" /etc/chrony.conf
		systemctl restart chronyd
	fi
else
	systemctl disable --now --quiet le-lab-ntp.service 2>/dev/null
	rm -f /etc/systemd/system/le-lab-ntp.service /usr/local/lib/le-lab/ntp-server.py
	rmdir /usr/local/lib/le-lab 2>/dev/null
	systemctl daemon-reload
	if pkg_installed chrony; then
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge chrony >/dev/null 2>&1
	fi
	pkg_installed systemd-timesyncd || pkg_install systemd-timesyncd
	[ -f "$LAB_STATE/timesyncd.conf" ] && cp -a "$LAB_STATE/timesyncd.conf" /etc/systemd/timesyncd.conf
	for f in /etc/systemd/timesyncd.conf.d/*; do
		[ -e "$f" ] || continue
		grep -qxF "${f##*/}" "$LAB_STATE/timesyncd-d" 2>/dev/null || rm -f "$f"
	done
	systemctl stop systemd-timedated 2>/dev/null # rereads the NTP services when it starts again
	systemctl enable --now --quiet systemd-timesyncd
	timedatectl set-ntp true 2>/dev/null || true
	systemctl restart systemd-timesyncd
fi
# The firewall's configuration, as it was.
if [ -f "$LAB_STATE/firewalld.tar" ]; then
	rm -rf /etc/firewalld
	tar -C /etc -xf "$LAB_STATE/firewalld.tar"
	systemctl is-active --quiet firewalld && firewall-cmd -q --reload
elif [ -f "$LAB_STATE/ufw.tar" ]; then
	rm -rf /etc/ufw
	tar -C /etc -xf "$LAB_STATE/ufw.tar"
	ufw reload >/dev/null
fi
true
