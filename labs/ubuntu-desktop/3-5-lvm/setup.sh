command -v vgcreate >/dev/null || pkg_install lvm2
vgs vg1 >/dev/null 2>&1 && refuse "a volume group vg1 already exists; remove it first"
findmnt /mnt/home2 >/dev/null && refuse "something is mounted at /mnt/home2; unmount it first"
grep -Eq '^[^#]*[[:space:]]/mnt/home2[[:space:]]' /etc/fstab && refuse "/etc/fstab already mounts /mnt/home2; take that line out first"
disk_add 0 1G >/dev/null
disk_add 1 2G >/dev/null
# Task 3 looks at LVM's metadata archive from here on.
touch "$LAB_STATE/since"
