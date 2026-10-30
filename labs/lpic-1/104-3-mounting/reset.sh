ids=" LABEL=data LABEL=stick "
for p in /dev/loop40p1 /dev/loop41; do
	u=$(blkid -s UUID -o value "$p" 2>/dev/null); [ -n "$u" ] && ids="$ids UUID=$u "
done
awk -v ids="$ids" '
	/^[[:space:]]*#/ || NF < 2 { print; next }
	{ src = $1; gsub(/"/, "", src) }
	$2 == "/mnt/data" || $2 == "/mnt/stick" || index(ids, " " src " ") || src ~ /^\/dev\/loop4[01]/ { next }
	{ print }' /etc/fstab >/etc/fstab.le-lab && cat /etc/fstab.le-lab >/etc/fstab
rm -f /etc/fstab.le-lab
umount -l /mnt/data /mnt/stick 2>/dev/null
systemctl daemon-reload
rmdir /mnt/data /mnt/stick 2>/dev/null
true
