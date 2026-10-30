# Swap on the spare disks off, and their fstab lines out (by path or UUID).
for d in /dev/loop40p* /dev/mapper/vglab-*; do
	[ -b "$d" ] || continue
	swapoff "$d" 2>/dev/null
	u=$(blkid -s UUID -o value "$d" 2>/dev/null)
	[ -n "$u" ] && sed -i "/$u/d" /etc/fstab
done
u=$(cat "$LAB_STATE/oldswap-uuid" 2>/dev/null)
[ -n "$u" ] && sed -i "/$u/d" /etc/fstab
sed -i -E '/^[^#]*(\/dev\/loop40|vglab)/d' /etc/fstab
systemctl daemon-reload
vgchange -an vglab >/dev/null 2>&1
true
