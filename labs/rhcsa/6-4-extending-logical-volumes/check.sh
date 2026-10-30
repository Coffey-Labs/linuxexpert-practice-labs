# Sizes in whole MiB.
lv_mib() { lvs --noheadings --units m --nosuffix -o lv_size "vg_lab/$1" 2>/dev/null | awk '{printf "%d", $1}'; }
fs_mib() {
	case $(blkid -s TYPE -o value "/dev/vg_lab/$1") in
	xfs) xfs_info "/dev/vg_lab/$1" 2>/dev/null | awk -F'[ =,]+' '/^data/ {for (i = 1; i < NF; i++) {if ($i == "bsize") b = $(i + 1); if ($i == "blocks") n = $(i + 1)} print int(b * n / 1048576); exit}' ;;
	ext*) dumpe2fs -h "/dev/vg_lab/$1" 2>/dev/null | awk -F: '/^Block count/ {n = $2} /^Block size/ {b = $2} END {print int(b * n / 1048576)}' ;;
	esac
}
# The file system fills its volume (within 4 MiB).
fills() { local l f; l=$(lv_mib "$1"); f=$(fs_mib "$1"); [ -n "$f" ] && [ $((l - f)) -le 4 ]; }
# MiB of lv_data on PVs of /dev/loop41.
on_new_pv() { lvs --noheadings --units m --nosuffix -o seg_size,devices --segments vg_lab/lv_data 2>/dev/null | awk '$2 ~ /^\/dev\/loop41/ {s += $1} END {printf "%d", s}'; }

task 1 "lv_data and its file system grown by 200 MiB, mounted"
need "/data is still mounted from lv_data" '[ "$(findmnt -n -o SOURCE /data)" = /dev/mapper/vg_lab-lv_data ]'
need "lv_data is at least 700 MiB" '[ "$(lv_mib lv_data)" -ge 696 ]'
need "the XFS file system fills lv_data" fills lv_data
need "/data/keep.txt is still there" grep -q "Keep this file" /data/keep.txt

task 2 "lv_logs grown by 100 MiB, then its file system"
need "/logs is still mounted from lv_logs" '[ "$(findmnt -n -o SOURCE /logs)" = /dev/mapper/vg_lab-lv_logs ]'
need "lv_logs is at least 400 MiB" '[ "$(lv_mib lv_logs)" -ge 396 ]'
need "the ext4 file system fills lv_logs" fills lv_logs
need "df -h /logs shows the larger size" '[ "$(df -BM --output=size /logs | tail -n1 | tr -dc 0-9)" -ge $(( $(state_get logs-df) + 80 )) ]'
need "/logs/keep.txt is still there" grep -q "Keep this file" /logs/keep.txt

task 3 "vg_lab filled, then lv_data grown onto /dev/loop41"
need "/dev/loop41 (or a partition on it) is in vg_lab" 'pvs --noheadings -o pv_name,vg_name 2>/dev/null | awk "\$1 ~ /^\/dev\/loop41/ && \$2 == \"vg_lab\"" | grep -q .'
need "vg_lab has two physical volumes" '[ "$(vgs --noheadings -o pv_count vg_lab | tr -d " ")" = 2 ]'
need "/dev/loop40 has no free space left" '[ "$(pvs --noheadings --units m --nosuffix -o pv_free /dev/loop40 | awk "{printf \"%d\", \$1}")" = 0 ]'
need "lv_data has about 200 MiB on the new disk" '[ "$(on_new_pv)" -ge 196 ]'
need "the XFS file system fills lv_data" fills lv_data
need "/data/keep.txt is still there" grep -q "Keep this file" /data/keep.txt
