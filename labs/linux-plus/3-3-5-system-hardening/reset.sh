systemctl disable --now --quiet legacy-console.service 2>/dev/null
rm -f /etc/systemd/system/legacy-console.service /usr/local/lib/le-lab/legacyd.py
rmdir /usr/local/lib/le-lab 2>/dev/null
systemctl daemon-reload
rm -f /usr/local/bin/sysreport /usr/sbin/netprobe
umount /mnt/nx 2>/dev/null
rmdir /mnt/nx 2>/dev/null
true
