# Size of a logical volume in whole MiB.
lv_mib() { lvs --noheadings --units m --nosuffix -o lv_size "vg_lab/$1" 2>/dev/null | awk '{printf "%d", $1}'; }
in_fstab() { findmnt -s -n "$1" >/dev/null || [ -f "/etc/systemd/system/$(systemd-escape -p --suffix=mount "$1")" ]; }
# Print notes.txt as the snapshot holds it, mounting the snapshot read-only
# for a moment if it isn't mounted already.
snap_notes() {
	local m
	m=$(findmnt -rn -o TARGET -S /dev/mapper/vg_lab-lv_data_snap | head -n1)
	if [ -n "$m" ]; then cat "$m/notes.txt"; return; fi
	m=$(mktemp -d)
	mount -o ro,nouuid /dev/vg_lab/lv_data_snap "$m" || { rmdir "$m"; return 1; }
	cat "$m/notes.txt"
	umount "$m"; rmdir "$m"
}

task 1 "vg_lab and an XFS lv_data mounted at /data at boot"
need "volume group vg_lab exists" vgs vg_lab
need "logical volume vg_lab/lv_data exists" lvs vg_lab/lv_data
need "lv_data holds an XFS filesystem" '[ "$(blkid -s TYPE -o value /dev/vg_lab/lv_data)" = xfs ]'
need "/data is mounted from lv_data" '[ "$(findmnt -n -o SOURCE /data)" = /dev/mapper/vg_lab-lv_data ]'
need "/data is mounted at boot (/etc/fstab)" in_fstab /data

task 2 "lv_data and its filesystem grown by 500 MiB"
need "lv_data is about 1.5 GiB (1 GiB + 500 MiB)" '[ "$(lv_mib lv_data)" -ge 1500 ] && [ "$(lv_mib lv_data)" -le 1560 ]'
need "the filesystem on /data has grown too" '[ "$(df -BM --output=size /data | tail -n1 | tr -dc 0-9)" -ge 1450 ]'

task 3 "Snapshot lv_data_snap holds the old notes.txt"
need "lv_data_snap is a snapshot of lv_data" '[ "$(lvs --noheadings -o origin vg_lab/lv_data_snap | tr -d " ")" = lv_data ]'
need "the snapshot is still valid (not full)" 'lvs --noheadings -o lv_attr vg_lab/lv_data_snap | awk "{exit substr(\$1,5,1) == \"I\"}"'
need "/data/notes.txt says version 2" grep -qx 'version 2' /data/notes.txt
need "notes.txt in the snapshot says version 1" '[ "$(snap_notes)" = "version 1" ]'

task 4 "/dev/loop42 in vg_lab, /dev/loop40 taken out"
need "/dev/loop42 is in vg_lab" '[ "$(pvs --noheadings -o vg_name /dev/loop42 2>/dev/null | tr -d " ")" = vg_lab ]'
need "/dev/loop40 is no longer in vg_lab" '[ "$(pvs --noheadings -o vg_name /dev/loop40 2>/dev/null | tr -d " ")" != vg_lab ]'
need "/data is still mounted from lv_data" '[ "$(findmnt -n -o SOURCE /data)" = /dev/mapper/vg_lab-lv_data ]'

task 5 "ext4 lv_files shrunk to 600 MiB with its files intact"
need "logical volume vg_lab/lv_files exists" lvs vg_lab/lv_files
need "lv_files holds an ext4 filesystem" '[ "$(blkid -s TYPE -o value /dev/vg_lab/lv_files)" = ext4 ]'
need "lv_files is 600 MiB" '[ "$(lv_mib lv_files)" -ge 596 ] && [ "$(lv_mib lv_files)" -le 604 ]'
need "/files is mounted from lv_files" '[ "$(findmnt -n -o SOURCE /files)" = /dev/mapper/vg_lab-lv_files ]'
need "/files is mounted at boot (/etc/fstab)" in_fstab /files
need "/files/services is a readable copy of /etc/services" cmp -s /files/services /etc/services
