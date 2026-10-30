# Unmount everything from vg_lab and take its lines out of /etc/fstab
# (by name or by UUID); the spare disks themselves are removed afterwards.
for lv in $(lvs --noheadings -o lv_path vg_lab 2>/dev/null); do
	uuid=$(blkid -s UUID -o value "$lv" 2>/dev/null)
	[ -n "$uuid" ] && sed -i "/$uuid/d" /etc/fstab
done
sed -i '/vg_lab/d' /etc/fstab
for m in /mnt/snap /files /data; do
	findmnt -rn -o SOURCE "$m" 2>/dev/null | grep -q vg_lab && umount -l "$m"
done
findmnt -rn -o TARGET,SOURCE | awk '$2 ~ /vg_lab/ {print $1}' | sort -r | xargs -r -n1 umount -l
systemctl daemon-reload
vgchange -an vg_lab >/dev/null 2>&1
rmdir /mnt/snap /files /data 2>/dev/null
true
