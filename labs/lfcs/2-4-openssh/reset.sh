systemctl disable --now --quiet le-lab-peer-sshd.service le-lab-peer-web.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-peer-sshd.service /etc/systemd/system/le-lab-peer-web.service
rm -rf /srv/le-peer-web
pkill -f 'ssh .*-L *8080:' 2>/dev/null

# sshd's configuration, its port label and socket.
if [ -f "$LAB_STATE/ssh.tar" ]; then
	rm -f /etc/ssh/sshd_config.d/* /etc/ssh/ssh_config.d/*
	tar -C /etc -xf "$LAB_STATE/ssh.tar"
fi
if [ -z "$(state_get had-2222)" ] && command -v semanage >/dev/null; then
	semanage port -d -t ssh_port_t -p tcp 2222 2>/dev/null
fi
for f in /etc/systemd/system/ssh.socket.d/*; do
	[ -e "$f" ] || continue
	grep -qxF "${f##*/}" "$LAB_STATE/socket-d" 2>/dev/null || rm -f "$f"
done
systemctl daemon-reload
if is_rhel; then
	systemctl restart sshd
else
	systemctl restart ssh.socket 2>/dev/null
	systemctl restart ssh.service 2>/dev/null
fi

# The client side.
if [ -f "$LAB_STATE/root-ssh-config" ]; then
	cp -a "$LAB_STATE/root-ssh-config" /root/.ssh/config
else
	rm -f /root/.ssh/config
fi
rm -rf /root/lab-keys
[ -n "$(state_get had-srv-sftp)" ] || rm -rf /srv/sftp

# Users go with users_remove; the groups and the student's membership here.
u=$(state_get added-user)
[ -n "$u" ] && gpasswd -d "$u" sshusers >/dev/null 2>&1
users_remove
while read -r g; do groupdel "$g" 2>/dev/null; done <"$LAB_STATE/groups" 2>/dev/null
true
