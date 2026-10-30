command -v rsync >/dev/null || refuse "rsync isn't installed; install it first (the chapter uses it on both machines)"
[ -x /usr/sbin/sshd ] || refuse "sshd isn't installed; install openssh-server first"
rm -rf /tmp/src /tmp/dst /tmp/dst2 /tmp/other-etc /tmp/vdb.img
user_add alex -s /bin/bash
peer_up
# The peer's sshd, on the peer's own address.
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
systemctl daemon-reload
systemctl enable --now --quiet le-lab-peer-sshd.service
# A small disk with something on it to image.
disk_add 0 64M >/dev/null
mkfs.ext4 -q -L labdata /dev/loop40
m=$(mktemp -d); mount /dev/loop40 "$m"; cp -r /etc/ssh "$m/"; umount "$m"; rmdir "$m"
