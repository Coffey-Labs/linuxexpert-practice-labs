if id alice >/dev/null 2>&1; then
	refuse "user alice already exists; task 2 creates her. Remove her (userdel -r alice) and start the lab again."
fi
user_add tester
# A marker in /var/log/secure: tasks 1 and 2 look for logins after it.
token=le-lab-$(date +%s)-$RANDOM
state_set token "$token"
state_set since "$(date +%s)"
# Written straight into the file: through logger it can arrive late.
printf '%s %s le-lab: lab started %s\n' "$(date '+%b %e %T')" "$(hostname -s)" "$token" >>/var/log/secure
peer_up
# The peer's own sshd; logins to it come from 10.99.0.1.
cat >/etc/systemd/system/le-lab-peer-sshd.service <<'X'
[Unit]
Description=Practice lab sshd on the peer
Requires=le-lab-peer.service
After=le-lab-peer.service network.target

[Service]
NetworkNamespacePath=/run/netns/lepeer
ExecStartPre=/bin/mkdir -p /run/sshd
ExecStart=/usr/sbin/sshd -D -o ListenAddress=10.99.0.2:22 -o PidFile=none -o PasswordAuthentication=yes -o KbdInteractiveAuthentication=yes
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-peer-sshd.service
