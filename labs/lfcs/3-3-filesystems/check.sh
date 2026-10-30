# fstab_src MOUNTPOINT: the device column of its /etc/fstab line, quotes removed.
fstab_src() { awk -v m="$1" '!/^[[:space:]]*#/ && $2 == m {print $1}' /etc/fstab | tr -d '"' | head -n1; }
# e2 FIELD: a value from the ext4 superblock on /dev/loop40p2.
e2() { dumpe2fs -h /dev/loop40p2 2>/dev/null | sed -n "s/^$1: *//p"; }
sectors() { cat "/sys/class/block/$1/$2"; }

task 1 "GPT, 2 GiB XFS partition labeled backup, at /backup by label"
need "/dev/loop40 has a GPT partition table" '[ "$(blkid -p -s PTTYPE -o value /dev/loop40)" = gpt ]'
need "/dev/loop40p1 is 2 GiB" '[ "$(sectors loop40p1 size)" -ge 4100000 ] && [ "$(sectors loop40p1 size)" -le 4200000 ]'
need "/dev/loop40p1 holds XFS" '[ "$(blkid -s TYPE -o value /dev/loop40p1)" = xfs ]'
need "the XFS filesystem is labeled backup" '[ "$(blkid -s LABEL -o value /dev/loop40p1)" = backup ]'
need "/backup is mounted from /dev/loop40p1" '[ "$(findmnt -n -o SOURCE /backup)" = /dev/loop40p1 ]'
need "/etc/fstab mounts /backup by LABEL=backup" '[ "$(fstab_src /backup)" = LABEL=backup ]'

task 2 "ext4 on /dev/loop40p2, 1% reserved, at /data by UUID"
need "/dev/loop40p2 holds ext4" '[ "$(blkid -s TYPE -o value /dev/loop40p2)" = ext4 ]'
need "only about 1% is reserved for root" 'r=$(e2 "Reserved block count"); b=$(e2 "Block count"); [ "$r" -gt 0 ] && [ $((r * 10000 / b)) -le 105 ]'
need "/data is mounted from /dev/loop40p2" '[ "$(findmnt -n -o SOURCE /data)" = /dev/loop40p2 ]'
need "/etc/fstab mounts /data by its UUID" '[ "$(fstab_src /data)" = "UUID=$(blkid -s UUID -o value /dev/loop40p2)" ]'

task 3 "ext4 filesystem damaged and repaired"
need "/dev/loop40p2 holds ext4" '[ "$(blkid -s TYPE -o value /dev/loop40p2)" = ext4 ]'
need "a full check (e2fsck -f) has run since the filesystem was made" '[ "$(date -d "$(e2 "Last checked")" +%s)" -gt "$(date -d "$(e2 "Filesystem created")" +%s)" ]'
need "e2fsck -fn finds no damage left" '! e2fsck -fn /dev/loop40p2 2>&1 | grep -Eq "Resize inode not valid|Inode 7, i_blocks"'

task 4 "Disk grown to 4 GiB, partition 2 and its filesystem fill it"
need "/dev/loop40 is 4 GiB" '[ "$(blockdev --getsize64 /dev/loop40)" -ge 4294967296 ]'
need "/dev/loop40p2 reaches the end of the disk" '[ $(( $(sectors loop40 size) - $(sectors loop40p2 start) - $(sectors loop40p2 size) )) -le 4096 ]'
need "the ext4 filesystem fills the partition" '[ $(( $(e2 "Block count") * $(e2 "Block size") / 1048576 )) -ge $(( $(sectors loop40p2 size) / 2048 - 8 )) ]'
need "/data is still mounted" '[ "$(findmnt -n -o SOURCE /data)" = /dev/loop40p2 ]'
