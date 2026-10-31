rm -rf /root/practice /root/practice.tar.gz /root/conf-files.txt /root/editme.txt /root/scripts /tmp/private.txt
if id bob >/dev/null 2>&1; then
	pkill -KILL -u bob 2>/dev/null
	userdel -r bob 2>/dev/null
fi
[ -f "$LAB_STATE/bashrc" ] && cp -a "$LAB_STATE/bashrc" /root/.bashrc
if [ -z "$(state_get had-nano)" ] && pkg_installed nano; then
	if is_rhel; then dnf -y -q remove nano >/dev/null; else DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge nano >/dev/null 2>&1; fi
fi
# sshd as it was: removed if task 3 installed it, else its settings back.
if [ -z "$(state_get had-sshd)" ]; then
	if pkg_installed openssh-server; then
		if is_rhel; then dnf -y -q remove openssh-server >/dev/null 2>&1; else DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge openssh-server >/dev/null 2>&1; fi
	fi
elif [ -f "$LAB_STATE/sshd.tar" ] &&
	[ "$(find /etc/ssh/sshd_config /etc/ssh/sshd_config.d -type f -exec sha256sum {} + 2>/dev/null | sort)" != "$(cat "$LAB_STATE/sshd.sums")" ]; then
	rm -rf /etc/ssh/sshd_config.d
	tar -C /etc -xf "$LAB_STATE/sshd.tar"
	command -v restorecon >/dev/null && restorecon -R /etc/ssh
	if is_rhel; then systemctl try-restart sshd; else systemctl try-restart ssh.service; fi
fi
true
