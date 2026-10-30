command -v sfdisk >/dev/null || pkg_install util-linux
pkg_installed parted || pkg_install parted
disk_add 0 1G >/dev/null
d1=$(disk_add 1 1G)
parted -s "$d1" mklabel gpt mkpart data 1MiB 501MiB mkpart lvm 501MiB 801MiB set 2 lvm on
udevadm settle
sfdisk --dump "$d1" | grep '^/dev/loop41p1 ' >"$LAB_STATE/loop41p1"
