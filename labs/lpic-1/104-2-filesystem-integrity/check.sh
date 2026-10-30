e2() { dumpe2fs -h /dev/loop40 2>/dev/null | sed -n "s/^$1: *//p"; }
mounted() { findmnt -rn -S "$1" >/dev/null; }

task 1 "ext4 with few inodes on /dev/loop40, filled up"
need "/dev/loop40 holds ext4" '[ "$(blkid -s TYPE -o value /dev/loop40)" = ext4 ]'
need "it has 1 KiB blocks" '[ "$(e2 "Block size")" = 1024 ]'
need "it has few inodes (mkfs.ext4 -N 1000)" '[ "$(e2 "Inode count")" -le 2000 ]'
need "every inode is in use" 'if mounted /dev/loop40; then [ "$(df --output=iavail /dev/loop40 | tail -n1 | tr -d " ")" = 0 ]; else [ "$(e2 "Free inodes")" = 0 ]; fi'

task 2 "Unmounted and checked with e2fsck -f"
need "/dev/loop40 isn't mounted" '! mounted /dev/loop40'
need "a full check (e2fsck -f) has run since it was made" '[ "$(date -d "$(e2 "Last checked")" +%s)" -gt "$(date -d "$(e2 "Filesystem created")" +%s)" ]'

task 3 "The first backup superblock"
need "/root/lab-answers/3 has the first backup superblock's block number" '[ -n "$(answer 3)" ] && [ "$(answer 3 | grep -oE "[0-9]+" | head -n1)" = "$(dumpe2fs /dev/loop40 2>/dev/null | grep -m1 -oE "Backup superblock at [0-9]+" | grep -oE "[0-9]+$")" ]'

task 4 "Label scratch, 2% reserved"
need "the label is scratch" '[ "$(e2 "Filesystem volume name")" = scratch ]'
need "2% of the blocks are reserved" 'r=$(e2 "Reserved block count"); b=$(e2 "Block count"); [ $((r * 1000 / b)) -ge 19 ] && [ $((r * 1000 / b)) -le 21 ]'

task 5 "XFS on /dev/loop41, checked"
need "/dev/loop41 holds XFS" '[ "$(blkid -s TYPE -o value /dev/loop41)" = xfs ]'
need "xfs_repair -n finds nothing wrong" 'mounted /dev/loop41 || xfs_repair -n /dev/loop41'

task 6 "A deleted file held open by tail" self
