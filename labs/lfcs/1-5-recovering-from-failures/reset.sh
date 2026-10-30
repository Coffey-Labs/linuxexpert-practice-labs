umount /mnt/missing /mnt/data 2>/dev/null
uuid=$(state_get data-uuid)
sed -i '/le-missing/d' /etc/fstab
[ -n "$uuid" ] && sed -i "/$uuid/d" /etc/fstab
sed -i '\|[[:space:]]/mnt/data[[:space:]]|d' /etc/fstab
systemctl daemon-reload
rmdir /mnt/missing /mnt/data 2>/dev/null
true
