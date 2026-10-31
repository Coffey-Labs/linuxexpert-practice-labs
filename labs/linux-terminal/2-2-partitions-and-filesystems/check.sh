D=$(state_get dev)
P=${D}p1
U=$(blkid -o value -s UUID "$P" 2>/dev/null)
# Partition size in bytes.
psize() { blockdev --getsize64 "$P" 2>/dev/null || echo 0; }

task 1 "GPT, one 1 GiB ext4 partition labeled data, mounted at /mnt/data by UUID"
need "$D has a GPT partition table" '[ "$(blkid -o value -s PTTYPE "$D")" = gpt ]'
need "$D has one partition, $P" '[ -b "$P" ] && [ "$(lsblk -nr -o TYPE "$D" | grep -c part)" = 1 ]'
need "$P is 1 GiB" 's=$(psize); [ "$s" -ge $((1024 * 1024 * 1016)) ] && [ "$s" -le $((1024 * 1024 * 1032)) ]'
need "$P holds ext4 labeled data" '[ "$(blkid -o value -s TYPE "$P")" = ext4 ] && [ "$(blkid -o value -s LABEL "$P")" = data ]'
need "/etc/fstab mounts UUID=$U at /mnt/data" '[ -n "$U" ] && awk -v u="UUID=$U" "\$1 == u && \$2 == \"/mnt/data\" && \$3 == \"ext4\"" /etc/fstab | grep -q .'
need "findmnt --verify reports no errors or warnings" 'findmnt --verify 2>&1 | grep -q "no errors or warnings"'
need "/mnt/data is mounted from it now" '[ -n "$U" ] && [ "$(findmnt -n -o UUID /mnt/data)" = "$U" ]'

task 2 "Partition deleted and recreated at the same start; keep.txt is back"
need "/root/lab-answers/2 holds $P's start sector" '[ "$(answer 2 | grep -o "[0-9]\+" | head -n1)" = "$(cat /sys/class/block/${P#/dev/}/start)" ]'
need "/mnt/data is mounted from $P" '[ -n "$U" ] && [ "$(findmnt -n -o UUID /mnt/data)" = "$U" ]'
need "/mnt/data/keep.txt contains keep me" '[ "$(cat /mnt/data/keep.txt)" = "keep me" ]'

task 3 "A full, read-only fsck, its output in /root/lab-answers/3"
need "/root/lab-answers/3 has fsck's output through pass 5" 'grep -q "Pass 5" /root/lab-answers/3'
need "it ends with the file and block counts" 'grep -Eq "[0-9]+/[0-9]+ files.*, [0-9]+/[0-9]+ blocks" /root/lab-answers/3'
need "fsck ran on the unmounted filesystem" '! grep -qi "is mounted" /root/lab-answers/3'
need "fsck changed nothing: no FILE SYSTEM WAS MODIFIED" '! grep -q "MODIFIED" /root/lab-answers/3'
