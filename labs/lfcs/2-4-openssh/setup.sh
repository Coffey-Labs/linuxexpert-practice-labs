# Users and groups.
for g in sshusers sftponly; do
	getent group $g >/dev/null || { groupadd $g; echo $g >>"$LAB_STATE/groups"; }
done
user_add alice -G sshusers
user_add bob
user_add sam -G sftponly
# Keep the student able to log in after AllowGroups.
if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != root ] && ! id -nG "$SUDO_USER" | grep -qw sshusers; then
	usermod -aG sshusers "$SUDO_USER"
	state_set added-user "$SUDO_USER"
fi
mkdir -p /root/lab-keys
chmod 700 /root/lab-keys
for u in alice bob sam; do
	rm -f /root/lab-keys/$u /root/lab-keys/$u.pub
	ssh-keygen -q -t ed25519 -N '' -C "$u@lab" -f /root/lab-keys/$u
	h=$(getent passwd $u | cut -d: -f6)
	install -d -m 700 -o $u -g $u "$h/.ssh"
	install -m 600 -o $u -g $u /root/lab-keys/$u.pub "$h/.ssh/authorized_keys"
	command -v restorecon >/dev/null && restorecon -R "$h/.ssh"
done

# Save the SSH configuration for reset.
tar -C /etc -cf "$LAB_STATE/ssh.tar" ssh
[ -f /root/.ssh/config ] && cp -a /root/.ssh/config "$LAB_STATE/root-ssh-config"
[ -d /srv/sftp ] && state_set had-srv-sftp 1
command -v getenforce >/dev/null && state_set selinux "$(getenforce)"
if command -v semanage >/dev/null && semanage port -l | grep -E '^ssh_port_t' | grep -qw 2222; then
	state_set had-2222 1
fi
ls /etc/systemd/system/ssh.socket.d >"$LAB_STATE/socket-d" 2>/dev/null || true

# The peer: its own sshd, and a web server on its 127.0.0.1:80.
peer_up
mkdir -p /srv/le-peer-web
echo 'Peer web server' >/srv/le-peer-web/index.html
cat >/etc/systemd/system/le-lab-peer-sshd.service <<'X'
[Unit]
Description=Practice lab sshd on the peer
Requires=le-lab-peer.service
After=le-lab-peer.service network.target

[Service]
NetworkNamespacePath=/run/netns/lepeer
ExecStartPre=/bin/mkdir -p /run/sshd
ExecStart=/usr/sbin/sshd -D -o ListenAddress=10.99.0.2:22 -o PidFile=none
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
X
cat >/etc/systemd/system/le-lab-peer-web.service <<'X'
[Unit]
Description=Practice lab web server on the peer's loopback
Requires=le-lab-peer.service
After=le-lab-peer.service

[Service]
NetworkNamespacePath=/run/netns/lepeer
ExecStart=/usr/bin/python3 -m http.server 80 --bind 127.0.0.1 --directory /srv/le-peer-web

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-peer-sshd.service le-lab-peer-web.service
