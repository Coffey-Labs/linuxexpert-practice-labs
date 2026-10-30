if [ -f "$LAB_STATE/motd" ]; then cp -a "$LAB_STATE/motd" /etc/motd; else rm -f /etc/motd; fi
if pkg_installed tree; then
	if is_rhel; then dnf -y -q remove tree >/dev/null; else DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge tree >/dev/null 2>&1; fi
fi
if [ -z "$(state_get had-at)" ]; then
	systemctl disable --now --quiet atd 2>/dev/null
	if is_rhel; then dnf -y -q remove at >/dev/null; else DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge at >/dev/null 2>&1; fi
elif [ -n "$(state_get atd-enabled)" ]; then
	systemctl enable --now --quiet atd 2>/dev/null
else
	systemctl disable --now --quiet atd 2>/dev/null
fi
true
