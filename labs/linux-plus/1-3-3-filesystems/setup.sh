for m in /mnt/e /mnt/x; do
	findmnt "$m" >/dev/null && refuse "something is mounted at $m; unmount it first"
done
disk_add 0 1G >/dev/null
disk_add 1 1G >/dev/null
