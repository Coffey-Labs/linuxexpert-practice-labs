lv_mib() { lvs --noheadings --units m --nosuffix -o lv_size "vglab/$1" 2>/dev/null | awk '{printf "%d", $1}'; }
pv_vg() { pvs --noheadings -o vg_name "$1" 2>/dev/null | tr -d ' '; }

task 1 "vglab with an ext4 volume one mounted at /mnt/one"
need "volume group vglab exists" vgs vglab
need "logical volume vglab/one exists" lvs vglab/one
need "one holds an ext4 filesystem" '[ "$(blkid -s TYPE -o value /dev/vglab/one)" = ext4 ]'
need "/mnt/one is mounted from one" '[ "$(findmnt -n -o SOURCE /mnt/one)" = /dev/mapper/vglab-one ]'

task 2 "two removed, one and its filesystem grown by 300 MiB"
need "logical volume two is gone" '! lvs vglab/two'
need "one is 900 MiB (600 + 300)" 'v=$(lv_mib one); [ -n "$v" ] && [ "$v" -ge 896 ] && [ "$v" -le 904 ]'
need "the filesystem on /mnt/one has grown too" '[ "$(df -BM --output=size /mnt/one | tail -n1 | tr -dc 0-9)" -ge 840 ]'

task 3 "/dev/loop40 emptied and taken out of vglab"
need "/dev/loop40 is no longer in vglab" '[ "$(pv_vg /dev/loop40)" != vglab ]'
need "/dev/loop41 is still in vglab" '[ "$(pv_vg /dev/loop41)" = vglab ]'
need "/mnt/one is still mounted from one" '[ "$(findmnt -n -o SOURCE /mnt/one)" = /dev/mapper/vglab-one ]'
