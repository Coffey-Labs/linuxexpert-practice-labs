[ -e /dev/md0 ] && [ -n "$(cat /sys/block/md0/md/array_state 2>/dev/null | grep -v clear)" ] &&
	refuse "/dev/md0 is already in use; stop it first"
findmnt /mnt/raid >/dev/null && refuse "something is mounted at /mnt/raid; unmount it first"
command -v mdadm >/dev/null || pkg_install mdadm
disk_add 0 1G >/dev/null
disk_add 1 1G >/dev/null
disk_add 2 1G >/dev/null
