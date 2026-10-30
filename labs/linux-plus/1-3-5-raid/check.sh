# A disk's role in md0 as mdadm --detail shows it: "active sync", "spare",
# "faulty", or nothing.
role() { mdadm --detail /dev/md0 2>/dev/null | awk -v d="$1" '$NF == d {$1 = $2 = $3 = $4 = $NF = ""; gsub(/^ +| +$/, ""); print}'; }
detail() { mdadm --detail /dev/md0 2>/dev/null | awk -F' : ' -v k="$1" '{gsub(/^ +/, "", $1)} $1 == k {print $2}'; }

task 1 "md0: RAID 1 with a spare, ext4, mounted at /mnt/raid, file says hello"
need "/dev/md0 is a RAID 1 array" '[ "$(detail "Raid Level")" = raid1 ]'
need "md0 mirrors two disks" '[ "$(detail "Raid Devices")" = 2 ]'
need "md0 holds ext4" '[ "$(blkid -s TYPE -o value /dev/md0)" = ext4 ]'
need "/mnt/raid is mounted from md0" '[ "$(findmnt -n -o SOURCE /mnt/raid)" = /dev/md0 ]'
need "/mnt/raid/file says hello" 'grep -qx hello /mnt/raid/file'

task 2 "loop40 failed, the spare loop42 took over"
need "/dev/loop42 is an active member of md0" '[[ $(role /dev/loop42) == "active sync"* ]]'
need "/dev/loop41 is still an active member" '[[ $(role /dev/loop41) == "active sync"* ]]'
need "md0 has finished rebuilding (clean, not degraded)" '
	s=$(detail State); [[ $s == clean* || $s == active* ]] && [[ $s != *degraded* && $s != *recovering* && $s != *resyncing* ]]'
need "/mnt/raid/file still says hello" 'grep -qx hello /mnt/raid/file'

task 3 "loop40 removed, wiped and added back as the spare"
need "/dev/loop40 is md0's spare" '[ "$(role /dev/loop40)" = spare ]'
need "md0 has no failed disks" '[ "$(detail "Failed Devices")" = 0 ]'
