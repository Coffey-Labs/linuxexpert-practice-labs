# Take the lab's lines out of /etc/fstab: /backup, /data, and anything
# naming the spare disk or its filesystems.
ids=" LABEL=backup "
for p in /dev/loop40p*; do
	[ -b "$p" ] || continue
	u=$(blkid -s UUID -o value "$p" 2>/dev/null)
	[ -n "$u" ] && ids="$ids UUID=$u "
done
awk -v ids="$ids" '
	/^[[:space:]]*#/ || NF < 2 { print; next }
	{ src = $1; gsub(/"/, "", src) }
	$2 == "/backup" || $2 == "/data" || index(ids, " " src " ") || src ~ /^\/dev\/loop40/ { next }
	{ print }' /etc/fstab >/etc/fstab.le-lab && cat /etc/fstab.le-lab >/etc/fstab
rm -f /etc/fstab.le-lab
for m in /backup /data; do
	findmnt -rn -o SOURCE "$m" 2>/dev/null | grep -q '^/dev/loop40' && umount -l "$m"
done
systemctl daemon-reload
rmdir /backup /data 2>/dev/null
true
