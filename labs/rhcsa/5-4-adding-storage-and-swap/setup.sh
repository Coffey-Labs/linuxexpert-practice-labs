command -v vgcreate >/dev/null || pkg_install lvm2
pkg_installed parted || pkg_install parted
vgs vglab >/dev/null 2>&1 && refuse "a volume group vglab already exists; the lab makes it. Remove it and start the lab again."
grep -q vglab /etc/fstab && refuse "/etc/fstab already names vglab; take that line out and start the lab again."
# Disk 0: a partition with data, and free space.
d0=$(disk_add 0 1G)
parted -s "$d0" mklabel gpt mkpart data 1MiB 301MiB
udevadm settle
[ -b "${d0}p1" ] || partx -u "$d0"
mkfs.ext4 -q -L le-data "${d0}p1"
m=$(mktemp -d)
mount "${d0}p1" "$m"
cp /etc/services "$m/services"
echo "Lab data: keep me" >"$m/keep.txt"
sha256sum "$m/services" "$m/keep.txt" | sed "s|$m/||" >"$LAB_STATE/data.sha"
umount "$m"; rmdir "$m"
sfdisk --dump "$d0" | grep "^${d0}p1 " >"$LAB_STATE/p1"
blkid -s UUID -o value "${d0}p1" >"$LAB_STATE/p1-uuid"
# Disk 1: volume group vglab with data and an old swap LV in fstab.
d1=$(disk_add 1 1G)
pvcreate -q "$d1" >/dev/null
vgcreate -q vglab "$d1" >/dev/null
lvcreate -q -y -n lvdata -L 200M vglab >/dev/null
lvcreate -q -y -n oldswap -L 128M vglab >/dev/null
mkswap -q /dev/vglab/oldswap >/dev/null
blkid -s UUID -o value /dev/vglab/oldswap >"$LAB_STATE/oldswap-uuid"
printf '/dev/vglab/oldswap none swap defaults 0 0\n' >>/etc/fstab
systemctl daemon-reload
swapon /dev/vglab/oldswap
