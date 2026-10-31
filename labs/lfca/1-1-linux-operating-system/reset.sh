systemctl stop le-lab-sleep.service 2>/dev/null
systemctl reset-failed le-lab-sleep.service 2>/dev/null
# tree as it was before the lab.
if [ -n "$(state_get had-tree)" ]; then
	pkg_installed tree || pkg_install tree
elif pkg_installed tree; then
	if is_rhel; then dnf -y -q remove tree >/dev/null; else DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge tree >/dev/null 2>&1; fi
fi
true
