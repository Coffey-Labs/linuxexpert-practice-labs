systemctl disable --now --quiet le-lab-watch.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-watch.service /usr/local/lib/le-lab/watch.sh
rmdir /usr/local/lib/le-lab 2>/dev/null
systemctl daemon-reload
sed -i -E 's/^[[:space:]]*SELINUX=(permissive|disabled)[[:space:]]*$/SELINUX=enforcing/' /etc/selinux/config
setenforce 1 2>/dev/null
true
