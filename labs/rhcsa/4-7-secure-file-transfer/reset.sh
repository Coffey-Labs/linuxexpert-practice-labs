systemctl disable --now --quiet le-lab-peer-sshd.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-peer-sshd.service
systemctl daemon-reload
rm -f /tmp/report.txt
true
