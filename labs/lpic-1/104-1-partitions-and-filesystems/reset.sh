# Lines the student may have added for the spare disks; the disks
# themselves (mounts and swap too) go afterwards.
ids=''
for p in /dev/loop40 /dev/loop40p* /dev/loop41; do
	[ -b "$p" ] || continue
	u=$(blkid -s UUID -o value "$p" 2>/dev/null); [ -n "$u" ] && ids="$ids UUID=$u "
	l=$(blkid -s LABEL -o value "$p" 2>/dev/null); [ -n "$l" ] && ids="$ids LABEL=$l "
done
awk -v ids="$ids" '
	/^[[:space:]]*#/ || NF < 2 { print; next }
	{ src = $1; gsub(/"/, "", src) }
	index(ids, " " src " ") || src ~ /^\/dev\/loop4[01]/ { next }
	{ print }' /etc/fstab >/etc/fstab.le-lab && cat /etc/fstab.le-lab >/etc/fstab
rm -f /etc/fstab.le-lab
systemctl daemon-reload
true
