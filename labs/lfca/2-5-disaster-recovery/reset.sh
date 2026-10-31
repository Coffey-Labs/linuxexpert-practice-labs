systemctl disable --now --quiet le-lab-peer-sshd.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-peer-sshd.service
systemctl daemon-reload
rm -rf /srv/projects /srv/site /root/projects.tar.gz
if [ -n "$(state_get no-rsync)" ] && pkg_installed rsync; then
	if is_rhel; then dnf -y -q remove rsync >/dev/null 2>&1; else DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge rsync >/dev/null 2>&1; fi
fi
true
