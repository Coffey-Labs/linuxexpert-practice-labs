umount /mnt/data 2>/dev/null
if [ -f "$LAB_STATE/fstab" ]; then
	cp -a "$LAB_STATE/fstab" /etc/fstab
	systemctl daemon-reload
fi
[ -n "$(state_get had-mnt-data)" ] || rmdir /mnt/data 2>/dev/null
true
