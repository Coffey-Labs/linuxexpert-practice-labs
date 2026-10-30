for m in /mnt/fat /mnt/ext /mnt/xfs; do
	findmnt -n "$m" >/dev/null 2>&1 && umount -l "$m"
done
# fstab lines for the spare disks, by path, UUID or mount point.
for d in /dev/loop40 /dev/loop41 /dev/loop42; do
	u=$(blkid -s UUID -o value "$d" 2>/dev/null)
	[ -n "$u" ] && sed -i "/$u/d" /etc/fstab
done
awk '/^[[:space:]]*#/ || NF < 2 { print; next }
	$1 ~ /^\/dev\/loop4[0-2]$/ || $2 == "/mnt/fat" || $2 == "/mnt/ext" || $2 == "/mnt/xfs" { next }
	{ print }' /etc/fstab >/etc/fstab.le-lab && cat /etc/fstab.le-lab >/etc/fstab
rm -f /etc/fstab.le-lab
systemctl daemon-reload
rmdir /mnt/fat /mnt/ext /mnt/xfs 2>/dev/null
true
