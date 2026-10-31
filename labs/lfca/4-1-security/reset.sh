systemctl disable --now --quiet le-lab-app.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-app.service
systemctl daemon-reload
rm -rf /srv/le-app /usr/local/lib/le-lab/httpd.py
rmdir /usr/local/lib/le-lab 2>/dev/null
rm -f /root/hash-me.txt /root/secret.txt /root/secret.txt.gpg

# sshd's configuration.
if [ -f "$LAB_STATE/ssh.tar" ]; then
	rm -f /etc/ssh/sshd_config.d/*
	tar -C /etc -xf "$LAB_STATE/ssh.tar"
	if is_rhel; then
		systemctl restart sshd
	else
		systemctl restart ssh.socket 2>/dev/null
		systemctl restart ssh.service 2>/dev/null
	fi
fi
# Root's new keys and gpg's files.
for k in /root/.ssh/id_*; do
	[ -e "$k" ] || continue
	grep -qxF "$k" "$LAB_STATE/root-keys" 2>/dev/null || rm -f "$k"
done
if [ -z "$(state_get had-gnupg)" ]; then
	gpgconf --kill gpg-agent 2>/dev/null
	rm -rf /root/.gnupg
fi

# The firewall as it was.
if is_rhel; then
	if grep -qx firewalld "$LAB_STATE/not-installed" 2>/dev/null; then
		systemctl disable --now --quiet firewalld 2>/dev/null
		dnf -y -q remove firewalld >/dev/null 2>&1
		rm -rf /etc/firewalld
	else
		if [ -f "$LAB_STATE/firewalld.tar" ]; then
			rm -rf /etc/firewalld
			tar -C /etc -xf "$LAB_STATE/firewalld.tar"
			command -v restorecon >/dev/null && restorecon -R /etc/firewalld
		fi
		if [ -n "$(state_get firewalld-was-active)" ]; then
			systemctl start firewalld && firewall-cmd -q --reload
		else
			systemctl stop firewalld 2>/dev/null
		fi
		if [ -n "$(state_get firewalld-was-enabled)" ]; then systemctl enable --quiet firewalld; else systemctl disable --quiet firewalld 2>/dev/null; fi
	fi
else
	[ -n "$(state_get ufw-was-active)" ] || ufw --force disable >/dev/null
	if [ -f "$LAB_STATE/ufw.tar" ]; then
		rm -rf /etc/ufw
		tar -C /etc -xf "$LAB_STATE/ufw.tar"
	fi
	[ -n "$(state_get ufw-was-active)" ] && ufw reload >/dev/null
fi
true
