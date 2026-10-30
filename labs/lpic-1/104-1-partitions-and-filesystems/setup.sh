command -v mkfs.btrfs >/dev/null || pkg_install btrfs-progs
modprobe btrfs 2>/dev/null || refuse "this kernel has no Btrfs support, which task 5 needs."
disk_add 0 4G >/dev/null
disk_add 1 4G >/dev/null
