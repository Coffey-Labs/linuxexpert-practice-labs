if mountpoint -q /mnt/data || [ -n "$(ls -A /mnt/data 2>/dev/null)" ]; then
	refuse "/mnt/data is in use; unmount or empty it and start the lab again."
fi
grep -Eq '^[^#]*[[:space:]]/mnt/data[[:space:]]' /etc/fstab &&
	refuse "/etc/fstab already mounts something at /mnt/data; remove that line and start the lab again."
cp -a /etc/fstab "$LAB_STATE/fstab"
[ -d /mnt/data ] && state_set had-mnt-data 1
dev=$(disk_add 0 2G)
state_set dev "$dev"
true
