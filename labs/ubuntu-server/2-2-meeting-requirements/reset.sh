systemctl disable --now --quiet le-lab-intranetd.service le-lab-reportdb.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-intranetd.service /etc/systemd/system/le-lab-reportdb.service
systemctl daemon-reload
rm -f /usr/local/lib/le-lab/listener.py
rmdir /usr/local/lib/le-lab 2>/dev/null
# Task 1's script.
u=$(state_get student)
h=$(getent passwd "${u:-root}" | cut -d: -f6)
rm -f "$h/check.sh" /root/check.sh
true
