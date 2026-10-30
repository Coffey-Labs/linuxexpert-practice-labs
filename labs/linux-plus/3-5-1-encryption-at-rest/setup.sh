[ -e /dev/mapper/lab ] && refuse "a device-mapper device called lab already exists; close it and start again"
findmnt /mnt/lab >/dev/null && refuse "something is mounted on /mnt/lab; unmount it and start again"
disk_add 0 256M >/dev/null
true
