rm -rf /root/practice /root/practice.tar.gz /root/conf-files.txt /root/editme.txt /root/scripts /tmp/private.txt
if id bob >/dev/null 2>&1; then
	pkill -KILL -u bob 2>/dev/null
	userdel -r bob 2>/dev/null
fi
[ -f "$LAB_STATE/bashrc" ] && cp -a "$LAB_STATE/bashrc" /root/.bashrc
if [ -z "$(state_get had-nano)" ] && pkg_installed nano; then
	if is_rhel; then dnf -y -q remove nano >/dev/null; else DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge nano >/dev/null 2>&1; fi
fi
true
