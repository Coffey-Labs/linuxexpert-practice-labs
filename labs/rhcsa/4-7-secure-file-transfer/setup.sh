for u in alice bob; do
	id "$u" >/dev/null 2>&1 && refuse "user $u already exists; the lab creates it. Remove it (userdel -r $u) and start the lab again."
done
[ -e /tmp/report.txt ] && refuse "/tmp/report.txt already exists; task 4 uploads it. Remove it and start the lab again."
pkg_installed rsync || pkg_install rsync
user_add alice
user_add bob
# alice's key logs in as bob.
install -d -m 700 -o alice -g alice /home/alice/.ssh /home/bob/.ssh
chown bob: /home/bob/.ssh
runuser -u alice -- ssh-keygen -q -t ed25519 -N '' -C alice@lab -f /home/alice/.ssh/id_ed25519
install -m 600 -o bob -g bob /home/alice/.ssh/id_ed25519.pub /home/bob/.ssh/authorized_keys
restorecon -R /home/alice/.ssh /home/bob/.ssh
# alice's project, dated January 2026.
P=/home/alice/proj
mkdir -p $P/docs
echo "Project notes" >$P/notes.txt
echo "db_password = not-a-real-one" >$P/secret.conf
echo "Design" >$P/docs/design.txt
chmod 640 $P/secret.conf
chmod 600 $P/docs/design.txt
chown -R alice: $P
touch -h -d '2026-01-15 10:00' $P/notes.txt $P/secret.conf $P/docs/design.txt $P/docs $P
echo "Quarterly report" >/home/alice/report.txt
chown alice: /home/alice/report.txt
(cd $P && find . -type f -printf '%P %m %T@ ' -exec sha256sum {} \; | awk '{print $1, $2, int($3), $4}') >"$LAB_STATE/files"
# The peer's own sshd.
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
