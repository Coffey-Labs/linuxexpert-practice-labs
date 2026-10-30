for u in alice bob; do
	id "$u" >/dev/null 2>&1 && refuse "user $u exists already; remove it first (userdel -r $u)"
done
listening 8000 tcp && refuse "something listens on TCP port 8000 already; stop it first"
user_add alice
user_add bob
echo "The launch code is 0000." >/home/alice/secret.txt
printf 'Meeting notes\nEverything is on schedule.\n' >/home/alice/notes.txt
chown alice: /home/alice/secret.txt /home/alice/notes.txt

# The peer, with its own sshd configuration and host keys in
# /etc/netns/lepeer/ssh, which "ip netns exec lepeer" mounts on /etc/ssh.
peer_up
mkdir -p /etc/netns/lepeer/ssh
k=$(mktemp -d)
mkdir -p "$k/etc/ssh"
ssh-keygen -A -f "$k" >/dev/null
mv "$k"/etc/ssh/ssh_host_* /etc/netns/lepeer/ssh/
rm -rf "$k"
cat >/etc/netns/lepeer/ssh/sshd_config <<'X'
# The peer's sshd configuration.
ListenAddress 10.99.0.2
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_rsa_key
PubkeyAuthentication yes
PasswordAuthentication yes
KbdInteractiveAuthentication no
UsePAM yes
X11Forwarding no
Subsystem sftp internal-sftp
X
command -v restorecon >/dev/null && restorecon -R /etc/netns 2>/dev/null
state_set hostkey "$(ssh-keygen -lf /etc/netns/lepeer/ssh/ssh_host_ed25519_key.pub | awk '{print $2}')"
cat >/etc/systemd/system/le-lab-peer-sshd.service <<'X'
[Unit]
Description=Practice lab sshd on the peer
Requires=le-lab-peer.service
After=le-lab-peer.service network.target

[Service]
NetworkNamespacePath=/run/netns/lepeer
BindPaths=/etc/netns/lepeer/ssh:/etc/ssh
ExecStartPre=/bin/mkdir -p /run/sshd
ExecStart=/usr/sbin/sshd -D -o PidFile=none
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-peer-sshd.service
true
