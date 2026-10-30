# Swap files the student added: off, out of fstab, deleted.
swapon --show=NAME,TYPE --noheadings | awk '$2 == "file" {print $1}' | while read -r f; do
	grep -qxF "$f" "$LAB_STATE/old-swaps" 2>/dev/null && continue
	swapoff "$f"
	sed -i "\\|^[[:space:]]*$f[[:space:]]|d" /etc/fstab
	rm -f "$f"
done
# vg_lab: unmounted and out of fstab; the spare disk goes afterwards.
uuid=$(blkid -s UUID -o value /dev/mapper/vg_lab-lv_data 2>/dev/null)
[ -n "$uuid" ] && sed -i "/$uuid/d" /etc/fstab
sed -i '/vg_lab/d' /etc/fstab
findmnt -rn -o TARGET,SOURCE | awk '$2 ~ /vg_lab/ {print $1}' | sort -r | xargs -r -n1 umount -l
systemctl daemon-reload
vgchange -an vg_lab >/dev/null 2>&1
true
