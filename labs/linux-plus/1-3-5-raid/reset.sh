findmnt /mnt/raid >/dev/null && umount -l /mnt/raid
# Stop every array built from the spare disks, then wipe their superblocks.
for md in /sys/block/md*; do
	[ -e "$md" ] || continue
	ls "$md/slaves" 2>/dev/null | grep -q '^loop4[0-9]' && mdadm --stop "/dev/${md##*/}" >/dev/null 2>&1
done
for dev in /dev/loop40 /dev/loop41 /dev/loop42; do
	[ -e "$dev" ] && mdadm --zero-superblock "$dev" >/dev/null 2>&1
done
rmdir /mnt/raid 2>/dev/null
true
