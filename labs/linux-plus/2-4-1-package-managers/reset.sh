if is_rhel; then
	dnf versionlock delete bash >/dev/null 2>&1
	if [ -z "$(state_get had-versionlock)" ] && pkg_installed python3-dnf-plugin-versionlock; then
		dnf -y -q remove python3-dnf-plugin-versionlock >/dev/null
	fi
	pkg_installed tree && dnf -y -q remove tree >/dev/null
else
	apt-mark unhold bash >/dev/null 2>&1
	pkg_installed tree && DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge tree >/dev/null 2>&1
fi
true
