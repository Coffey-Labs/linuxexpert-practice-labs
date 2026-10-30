for m in /mnt/fat /mnt/ext /mnt/xfs; do
	findmnt -n "$m" >/dev/null && refuse "$m is already mounted; unmount it and start again"
done
user_add student
disk_add 0 256M >/dev/null
disk_add 1 256M >/dev/null
disk_add 2 512M >/dev/null
