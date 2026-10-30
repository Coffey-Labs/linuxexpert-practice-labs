user_add student
user_add alice
state_set start "$(date '+%Y-%m-%d %H:%M:%S')"
peer_up
hosts_add "$LE_PEER_ADDR server1.lab.example server1"
mkdir -p /etc/ssh/server1/sshd_config.d
keys=''
for t in ed25519 ecdsa rsa; do
	[ -f /etc/ssh/ssh_host_${t}_key ] && keys="${keys}HostKey /etc/ssh/ssh_host_${t}_key
"
done
[ -n "$keys" ] || { ssh-keygen -A >/dev/null; keys='HostKey /etc/ssh/ssh_host_ed25519_key
'; }
cat >/etc/ssh/server1/sshd_config <<X
# sshd configuration of the lab's server1 (10.99.0.2).
# Files in sshd_config.d come first: the first value set for an option wins.
Include /etc/ssh/server1/sshd_config.d/*.conf

ListenAddress 10.99.0.2
PidFile none
${keys}PermitRootLogin no
PasswordAuthentication yes
KbdInteractiveAuthentication no
PubkeyAuthentication yes
UsePAM yes
SyslogFacility AUTHPRIV
Subsystem sftp /usr/libexec/openssh/sftp-server
X
command -v restorecon >/dev/null && restorecon -R /etc/ssh/server1
cat >/etc/systemd/system/le-lab-server1-sshd.service <<'X'
[Unit]
Description=Practice lab sshd on server1
Requires=le-lab-peer.service
After=le-lab-peer.service network.target

[Service]
NetworkNamespacePath=/run/netns/lepeer
ExecStartPre=/usr/sbin/sshd -t -f /etc/ssh/server1/sshd_config
ExecStart=/usr/sbin/sshd -D -f /etc/ssh/server1/sshd_config
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
X
# The journal may not be kept across reboots: copy sshd's complaints about
# file modes for the check.
cat >/etc/systemd/system/le-lab-server1-log.service <<X
[Unit]
Description=Practice lab: keep server1's file-mode complaints
After=systemd-journald.service

[Service]
ExecStart=/bin/sh -c 'journalctl -f -n 0 -q -u le-lab-server1-sshd | grep --line-buffered "bad ownership or modes" >>$LAB_STATE/bad-modes'

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-server1-log.service le-lab-server1-sshd.service
