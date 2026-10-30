U0=$(blkid -s UUID -o value /dev/loop40 2>/dev/null)
held() { find /proc/[0-9]*/fd -lname '/mnt/scratch/*(deleted)' 2>/dev/null | grep -q .; }

task 1 "/mnt/lab mounted from /dev/loop40 through fstab"
need "fstab's /mnt/lab line uses /dev/loop40's UUID" '[ -n "$U0" ] && findmnt --fstab -n -o SOURCE /mnt/lab | grep -qx "UUID=$U0"'
need "fstab has no line with the bad UUID" '! grep -q "00000000-0000-0000-0000-000000000000" /etc/fstab'
need "/dev/loop40 is mounted on /mnt/lab" '[ "$(findmnt -n -o SOURCE /mnt/lab)" = /dev/loop40 ]'

task 2 "Room on /mnt/inodes again"
need "/root/lab-answers/2 names the resource" 'grep -qi inode /root/lab-answers/2'
need "/mnt/inodes/data/records.txt is still there" 'grep -q "Customer data" /mnt/inodes/data/records.txt'
need "a new file can be created in /mnt/inodes/data" 'f=/mnt/inodes/data/.le-check; touch $f && rm -f $f'

task 3 "The space on /mnt/scratch freed"
need "/root/lab-answers/3 names the process" 'grep -Eqi "reportd|report-cache" /root/lab-answers/3'
need "no process holds a deleted file on /mnt/scratch" '! held'
need "/mnt/scratch is mostly free" '[ "$(df --output=pcent /mnt/scratch | tail -1 | tr -dc 0-9)" -lt 50 ]'
