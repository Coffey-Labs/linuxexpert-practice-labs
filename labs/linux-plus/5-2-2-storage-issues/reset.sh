systemctl stop report-cache.service 2>/dev/null
rm -f /etc/systemd/system/report-cache.service /usr/local/lib/le-lab/reportd.py
rmdir /usr/local/lib/le-lab 2>/dev/null
umount /mnt/lab /mnt/inodes /mnt/scratch 2>/dev/null
# fstab without the lab's three lines.
awk '$2 != "/mnt/lab" && $2 != "/mnt/inodes" && $2 != "/mnt/scratch"' /etc/fstab >"$LAB_STATE/fstab.new" &&
	cat "$LAB_STATE/fstab.new" >/etc/fstab
systemctl daemon-reload
rmdir /mnt/lab /mnt/inodes /mnt/scratch 2>/dev/null
true
