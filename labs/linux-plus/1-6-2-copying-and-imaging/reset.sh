systemctl disable --now --quiet le-lab-peer-sshd.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-peer-sshd.service
systemctl daemon-reload
rm -rf /tmp/src /tmp/dst /tmp/dst2 /tmp/other-etc /tmp/vdb.img
true
