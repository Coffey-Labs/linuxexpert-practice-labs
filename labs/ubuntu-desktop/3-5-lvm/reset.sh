# Unmount home2 and take its line out of /etc/fstab (by name or UUID);
# the spare disks themselves are removed afterwards.
uuid=$(blkid -s UUID -o value /dev/vg1/home2 2>/dev/null)
[ -n "$uuid" ] && sed -i "/$uuid/d" /etc/fstab
sed -i -E '/vg1-home2|vg1\/home2|[[:space:]]\/mnt\/home2[[:space:]]/d' /etc/fstab
findmnt -rn -o TARGET,SOURCE | awk '$2 ~ /vg1-/ {print $1}' | sort -r | xargs -r -n1 umount -l
systemctl daemon-reload
vgchange -an vg1 >/dev/null 2>&1
rmdir /mnt/home2 2>/dev/null
true
