disk_add 0 512M >/dev/null
mkfs.ext4 -q -L spare /dev/loop40
user_add alice
mkdir -p /srv/shared
echo 'Shared notes' >/srv/shared/welcome.txt
# What /tmp looked like before, for reset.
if findmnt -s -n /tmp >/dev/null; then state_set tmp-in-fstab yes; fi
for f in /etc/systemd/system/tmp.mount /etc/systemd/system/tmp.mount.d; do
	[ -e "$f" ] && state_set "had-${f##*/}" yes
done
# A /tmp that already refuses programs would pass task 4 untouched.
if findmnt -n -o OPTIONS /tmp | grep -qw noexec; then
	mount -o remount,exec /tmp
fi
