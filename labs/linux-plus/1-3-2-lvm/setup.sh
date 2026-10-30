vgs vglab >/dev/null 2>&1 && refuse "a volume group vglab already exists; remove it first"
findmnt /mnt/one >/dev/null && refuse "something is mounted at /mnt/one; unmount it first"
disk_add 0 1G >/dev/null
disk_add 1 1G >/dev/null
