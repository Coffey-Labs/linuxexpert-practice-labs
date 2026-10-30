command -v vgcreate >/dev/null || pkg_install lvm2
pkg_installed parted || pkg_install parted
for vg in vgdata vgold; do
	vgs "$vg" >/dev/null 2>&1 && refuse "a volume group $vg already exists; the lab makes or asks for it. Remove it and start the lab again."
done
d0=$(disk_add 0 1G)
parted -s "$d0" mklabel gpt mkpart a 1MiB 601MiB mkpart b 601MiB 901MiB
d1=$(disk_add 1 1G)
parted -s "$d1" mklabel gpt mkpart a 1MiB 401MiB mkpart b 401MiB 801MiB set 1 lvm on set 2 lvm on
udevadm settle
for p in "$d0"p1 "$d0"p2 "$d1"p1 "$d1"p2; do
	[ -b "$p" ] || partx -u "${p%p[0-9]}"
done
udevadm settle
pvcreate -q "$d1"p1 "$d1"p2 >/dev/null
vgcreate -q vgold "$d1"p1 "$d1"p2 >/dev/null
lvcreate -q -y -n lvone -L 300M vgold >/dev/null
lvcreate -q -y -n lvtwo -l 100%FREE vgold >/dev/null
