findmnt /mnt/lab >/dev/null && refuse "something is mounted at /mnt/lab; unmount it first"
grep -Eq '^[^#]*[[:space:]]/mnt/lab[[:space:]]' /etc/fstab && refuse "/etc/fstab already has a line for /mnt/lab; remove it first"
disk_add 0 512M >/dev/null
mkfs.ext4 -q /dev/loop40
state_set uuid "$(blkid -s UUID -o value /dev/loop40)"
