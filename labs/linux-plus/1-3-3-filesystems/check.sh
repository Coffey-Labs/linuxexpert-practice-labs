sb() { dumpe2fs -h /dev/loop40 2>/dev/null | awk -F: -v k="$1" '$1 == k {sub(/^[ \t]+/, "", $2); s = $2; for (i = 3; i <= NF; i++) s = s ":" $i; print s}'; }
fstype() { blkid -s TYPE -o value "$1" 2>/dev/null; }
inodes=$(sb 'Inode count')
first=$(sb 'First inode')

task 1 "ext4 with about 2000 inodes on loop40, XFS on loop41"
need "/dev/loop40 holds ext4" '[ "$(fstype /dev/loop40)" = ext4 ]'
need "the ext4 filesystem has about 2000 inodes (not tens of thousands)" '[ -n "$inodes" ] && [ "$inodes" -ge 1500 ] && [ "$inodes" -le 4096 ]'
need "/dev/loop41 holds XFS" '[ "$(fstype /dev/loop41)" = xfs ]'

task 2 "/mnt/e run out of inodes, the count noted, the files deleted"
need "/root/lab-answers/2 has the number of files that fit ($((inodes - first)))" '
	a=$(answer 2 | tr -dc 0-9); [ -n "$a" ] && [ "$a" -ge $((inodes - first - 2)) ] && [ "$a" -le $((inodes - first + 1)) ]'
need "the files are deleted again" '[ "$(sb "Free inodes")" -ge $((inodes - first - 2)) ]'

task 3 "ext4 checked with fsck, XFS benchmarked with fio"
need "/dev/loop40 isn't mounted" '! findmnt -S /dev/loop40'
need "fsck checked /dev/loop40 after it was made" '[ "$(date -d "$(sb "Last checked")" +%s)" -gt "$(date -d "$(sb "Filesystem created")" +%s)" ]'
need "fio is installed" 'command -v fio'
need "/dev/loop41 isn't mounted" '! findmnt -S /dev/loop41'
need "the test file is removed" '
	m=$(mktemp -d); mount -o ro /dev/loop41 "$m" || exit 1
	n=$(find "$m" -mindepth 1 | wc -l); umount "$m"; rmdir "$m"; [ "$n" = 0 ]'
