for m in /data /backups /mnt/archive; do
	findmnt -n "$m" >/dev/null && refuse "something is mounted on $m already; unmount it, take its line out of /etc/fstab, and start the lab again."
	findmnt --fstab -n "$m" >/dev/null && refuse "/etc/fstab already has a line for $m; take it out and start the lab again."
done
blkid -t LABEL=backups >/dev/null 2>&1 && refuse "a file system labeled backups already exists; the lab asks you to make it."
[ -d /data ] && state_set had-data 1
[ -d /backups ] && state_set had-backups 1
disk_add 0 1G >/dev/null
disk_add 1 1G >/dev/null
uuid=$(cat /proc/sys/kernel/random/uuid)
state_set bad-uuid "$uuid"
mkdir -p /mnt/archive
printf 'UUID=%s /mnt/archive xfs defaults,nofail 0 0\n' "$uuid" >>/etc/fstab
systemctl daemon-reload
