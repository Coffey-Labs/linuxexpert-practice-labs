fstype() { blkid -s TYPE -o value "$1" 2>/dev/null; }
mounted_from() { [ "$(findmnt -n -o SOURCE "$1")" = "$2" ]; }
# has_file DIR: a regular file somewhere in DIR, outside lost+found.
has_file() { find "$1" -xdev -type f -not -path '*/lost+found/*' -not -name 'le-check-*' 2>/dev/null | grep -q .; }
# xfs_has_file: the XFS file system on /dev/loop42 holds a file, mounting
# it read-only for a moment if it isn't mounted.
xfs_has_file() {
	local m rc
	m=$(findmnt -rn -o TARGET -S /dev/loop42 | head -n1)
	[ -n "$m" ] && { has_file "$m"; return; }
	m=$(mktemp -d)
	mount -o ro /dev/loop42 "$m" || { rmdir "$m"; return 1; }
	has_file "$m"; rc=$?
	umount "$m"; rmdir "$m"
	return $rc
}

task 1 "VFAT, ext4 and XFS file systems, each with a file in it"
need "/dev/loop40 holds a VFAT file system" '[ "$(fstype /dev/loop40)" = vfat ]'
need "/dev/loop41 holds an ext4 file system" '[ "$(fstype /dev/loop41)" = ext4 ]'
need "/dev/loop42 holds an XFS file system" '[ "$(fstype /dev/loop42)" = xfs ]'
need "/mnt/fat is mounted from /dev/loop40" mounted_from /mnt/fat /dev/loop40
need "/mnt/ext is mounted from /dev/loop41" mounted_from /mnt/ext /dev/loop41
need "there's a file in /mnt/fat" has_file /mnt/fat
need "there's a file in /mnt/ext" has_file /mnt/ext
need "there's a file on the XFS file system" xfs_has_file

task 2 "VFAT at /mnt/fat owned by student, at every boot"
need "/mnt/fat is mounted from /dev/loop40" mounted_from /mnt/fat /dev/loop40
need "/etc/fstab mounts /mnt/fat" 'findmnt -s -n /mnt/fat'
need "/etc/fstab mounts it with uid= for student" 'findmnt -s -n -o OPTIONS /mnt/fat | tr , "\n" | grep -Eqx "uid=(student|$(id -u student))"'
need "ls -l /mnt/fat shows student as the owner" '[ "$(stat -c %U /mnt/fat)" = student ]'
need "student can create a file in /mnt/fat" 'runuser -u student -- touch /mnt/fat/le-check-$$ && rm -f /mnt/fat/le-check-$$'

task 3 "The busy /mnt/xfs explained and unmounted"
need "/dev/loop42 holds an XFS file system" '[ "$(fstype /dev/loop42)" = xfs ]'
need "/root/lab-answers/3 names the program (your shell)" '[[ "$(answer 3)" =~ ^-?(ba|z|k|da|tc|c|fi)?sh$ ]]'
need "/mnt/xfs isn't mounted" '! findmnt -n /mnt/xfs'
