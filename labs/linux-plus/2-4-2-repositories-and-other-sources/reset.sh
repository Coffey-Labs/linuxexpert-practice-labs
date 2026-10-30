rm -rf /root/venv /root/src /usr/local/bin/hi
if is_rhel; then
	pkg_installed htop && dnf -y -q remove htop >/dev/null
	if [ -z "$(state_get had-crb)" ]; then dnf config-manager --set-disabled crb >/dev/null 2>&1; fi
	if [ -z "$(state_get had-epel)" ] && pkg_installed epel-release; then dnf -y -q remove epel-release >/dev/null; fi
else
	update-alternatives --auto editor >/dev/null 2>&1
fi
true
