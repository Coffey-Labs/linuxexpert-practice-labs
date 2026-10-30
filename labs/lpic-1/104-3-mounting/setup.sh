command -v fuser >/dev/null || pkg_install psmisc
d0=$(disk_add 0 1G)
parted -s "$d0" mklabel gpt mkpart data ext4 1MiB 100%
udevadm settle
[ -b "${d0}p1" ] || partx -u "$d0"
mkfs.ext4 -q -L data "${d0}p1"
d1=$(disk_add 1 256M)
mkfs.ext4 -q -L stick "$d1"
user_add uma
