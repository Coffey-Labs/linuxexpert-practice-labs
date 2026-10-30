if [ -n "$(state_get had-chrony)" ]; then
	if is_rhel; then
		[ -f "$LAB_STATE/chrony.conf" ] && cp -a "$LAB_STATE/chrony.conf" /etc/chrony.conf
	elif [ -f "$LAB_STATE/chrony.tar" ]; then
		rm -rf /etc/chrony
		tar -C /etc -xf "$LAB_STATE/chrony.tar"
	fi
	systemctl restart "$(pick chronyd chrony)" 2>/dev/null
elif pkg_installed chrony; then
	# The task installed it: take it out again.
	if is_rhel; then
		dnf -y -q remove chrony >/dev/null 2>&1
	else
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge chrony >/dev/null 2>&1
	fi
fi
if [ -n "$(state_get had-timesyncd)" ] && ! pkg_installed systemd-timesyncd; then
	pkg_install systemd-timesyncd
	systemctl enable --now --quiet systemd-timesyncd
fi
true
