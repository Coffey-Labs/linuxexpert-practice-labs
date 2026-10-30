systemctl disable --now --quiet le-lab-server1-sshd.service le-lab-server1-log.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-server1-sshd.service /etc/systemd/system/le-lab-server1-log.service
systemctl daemon-reload
rm -rf /etc/ssh/server1
true
