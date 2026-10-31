rm -rf /root/project /root/app.git /root/app-copy
[ -n "$(state_get had-gitconfig)" ] || rm -f /root/.gitconfig
if [ -n "$(state_get no-git)" ] && pkg_installed git; then
	if is_rhel; then dnf -y -q remove git >/dev/null 2>&1; else DEBIAN_FRONTEND=noninteractive apt-get -y -qq --autoremove purge git >/dev/null 2>&1; fi
fi
true
