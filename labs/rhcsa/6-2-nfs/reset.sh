findmnt -n /mnt/nfs >/dev/null 2>&1 && { umount /mnt/nfs 2>/dev/null || umount -l /mnt/nfs; }
awk '/^[[:space:]]*#/ || NF < 2 { print; next } $2 == "/mnt/nfs" || $2 == "/mnt/nfs/" { next } { print }' /etc/fstab >/etc/fstab.le-lab &&
	cat /etc/fstab.le-lab >/etc/fstab
rm -f /etc/fstab.le-lab
systemctl disable --now le-lab-nfs-server.service >/dev/null 2>&1
rm -f /etc/systemd/system/le-lab-nfs-server.service /etc/exports.d/le-lab.exports
systemctl daemon-reload
rm -rf /exports
rmdir /mnt/nfs 2>/dev/null
true
