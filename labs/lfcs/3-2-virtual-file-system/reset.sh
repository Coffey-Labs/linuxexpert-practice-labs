# Unmount what the tasks mount (the bind mount before alice's home goes).
for m in /home/alice/shared /scratch /data; do
	findmnt -n "$m" >/dev/null 2>&1 && umount -l "$m"
done
# Take their lines out of /etc/fstab, and the /tmp line if the lab added it.
uuid=$(blkid -s UUID -o value /dev/loop40 2>/dev/null)
drop="/data /scratch /home/alice/shared"
[ "$(state_get tmp-in-fstab)" = yes ] || drop="$drop /tmp"
awk -v drop=" $drop " -v uuid="${uuid:-none}" '
	/^[[:space:]]*#/ || NF < 2 { print; next }
	index(drop, " " $2 " ") || index($1, uuid) || $1 == "/dev/loop40" { next }
	{ print }' /etc/fstab >/etc/fstab.le-lab && cat /etc/fstab.le-lab >/etc/fstab
rm -f /etc/fstab.le-lab
[ "$(state_get had-tmp.mount)" = yes ] || rm -f /etc/systemd/system/tmp.mount
[ "$(state_get had-tmp.mount.d)" = yes ] || rm -rf /etc/systemd/system/tmp.mount.d
systemctl daemon-reload
# Programs may run from /tmp again (a tmpfs added for task 4 stays until
# the next boot).
findmnt -n /tmp >/dev/null && mount -o remount,exec,suid /tmp
rm -rf /srv/shared
rmdir /scratch /data 2>/dev/null
true
