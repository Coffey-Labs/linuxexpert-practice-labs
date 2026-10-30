for m in /data /backups /mnt/archive; do
	findmnt -rn -o SOURCE "$m" 2>/dev/null | grep -Eq "^/dev/(loop4|mapper/)" && umount -l "$m"
done
# Setup refused to start with fstab lines for these mount points, so every
# line for them is the lab's or the student's.
sed -i -E '\%^[^#[:space:]]+[[:space:]]+/(data|backups|mnt/archive)/?[[:space:]]%d' /etc/fstab
u=$(state_get bad-uuid)
[ -n "$u" ] && sed -i "/$u/d" /etc/fstab
systemctl daemon-reload
rmdir /mnt/archive 2>/dev/null
[ -n "$(state_get had-data)" ] || rmdir /data 2>/dev/null
[ -n "$(state_get had-backups)" ] || rmdir /backups 2>/dev/null
true
