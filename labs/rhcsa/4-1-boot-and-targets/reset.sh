sed -i '/le-nodisk/d' /etc/fstab
systemctl daemon-reload
umount /mnt/nodisk 2>/dev/null
rmdir /mnt/nodisk 2>/dev/null
true
