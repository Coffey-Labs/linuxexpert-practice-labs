id bkp >/dev/null 2>&1 && refuse "a user bkp already exists; remove it and start again"
for p in /root/.ssh/backup_key /srv/backups; do
	[ -e "$p" ] && refuse "$p already exists; move it away and start again"
done
command -v rsync >/dev/null || pkg_install rsync
ls /etc/systemd/system >"$LAB_STATE/units-before"
ls /usr/local/sbin /usr/local/bin 2>/dev/null >"$LAB_STATE/local-before" || true
# Task 3's file.
if [ -e /etc/motd ]; then cp -a /etc/motd "$LAB_STATE/motd.orig"; fi
printf 'Welcome to s1. Backups run nightly.\n' >/etc/motd
chown root:adm /etc/motd
chmod 640 /etc/motd
# A new file has a new inode or birth time, even with the old mtime.
state_set motd-id "$(stat -c "%i %w" /etc/motd)"
state_set motd-sum "$(md5sum </etc/motd)"
# The peer and its sshd.
peer_up
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
