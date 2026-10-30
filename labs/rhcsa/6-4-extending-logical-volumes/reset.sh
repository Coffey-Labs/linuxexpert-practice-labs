for m in /data /logs; do
	findmnt -rn -o SOURCE "$m" 2>/dev/null | grep -q vg_lab && umount -l "$m"
done
for lv in $(lvs --noheadings -o lv_path vg_lab 2>/dev/null); do
	uuid=$(blkid -s UUID -o value "$lv" 2>/dev/null)
	[ -n "$uuid" ] && sed -i "/$uuid/d" /etc/fstab
done
sed -i '/vg_lab/d' /etc/fstab
systemctl daemon-reload
vgchange -an vg_lab >/dev/null 2>&1
rmdir /data /logs 2>/dev/null
true
