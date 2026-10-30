UUID=$(state_get uuid)
[ -n "$UUID" ] && sed -i "/$UUID/d" /etc/fstab
sed -i -E '/^[^#]*[[:space:]]\/mnt\/lab[[:space:]]/d' /etc/fstab
systemctl daemon-reload
findmnt /mnt/lab >/dev/null && umount -l /mnt/lab
rmdir /mnt/lab 2>/dev/null
true
