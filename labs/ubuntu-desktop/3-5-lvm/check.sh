lv_mib() { lvs --noheadings --units m --nosuffix -o lv_size "vg1/$1" 2>/dev/null | awk '{printf "%d", $1}'; }
in_fstab() { findmnt -s -n "$1" >/dev/null || [ -f "/etc/systemd/system/$(systemd-escape -p --suffix=mount "$1")" ]; }
pv_vg() { pvs --noheadings -o vg_name "$1" 2>/dev/null | tr -d ' '; }
merged() {
	find /etc/lvm/archive -name 'vg1_*.vg' -newer "$LAB_STATE/since" -print0 2>/dev/null |
		xargs -0 -r grep -l "lvconvert --merge" | grep -q .
}

task 1 "vg1 on the first disk, home2 (ext4) mounted at /mnt/home2 at boot"
need "volume group vg1 exists" vgs vg1
need "/dev/loop40 is in vg1" '[ "$(pv_vg /dev/loop40)" = vg1 ]'
need "logical volume vg1/home2 exists" lvs vg1/home2
need "home2 is at least 800 MiB" '[ "$(lv_mib home2)" -ge 796 ]'
need "home2 holds an ext4 filesystem" '[ "$(blkid -s TYPE -o value /dev/vg1/home2)" = ext4 ]'
need "/mnt/home2 is mounted from home2" '[ "$(findmnt -n -o SOURCE /mnt/home2)" = /dev/mapper/vg1-home2 ]'
need "/mnt/home2 is mounted at boot (/etc/fstab)" in_fstab /mnt/home2

task 2 "home2 grown by 1.5 GiB onto both disks"
need "home2 is 800 MiB + 1.5 GiB (2336 MiB)" '[ "$(lv_mib home2)" -ge 2330 ] && [ "$(lv_mib home2)" -le 2340 ]'
need "both spare disks are in vg1" '[ "$(pv_vg /dev/loop40)" = vg1 ] && [ "$(pv_vg /dev/loop41)" = vg1 ]'
need "the filesystem on /mnt/home2 has grown too (about 2.3G)" '[ "$(df -BM --output=size /mnt/home2 | tail -n1 | tr -dc 0-9)" -ge 2200 ]'

task 3 "notes.txt back from a merged snapshot"
need "/mnt/home2/notes.txt exists" '[ -f /mnt/home2/notes.txt ]'
need "a snapshot of home2 was merged (lvconvert --merge)" merged
need "vg1 has no snapshot left" '! lvs --noheadings -o lv_attr vg1 2>/dev/null | grep -Eq "^[[:space:]]*[sS]"'
