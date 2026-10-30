lv_mib() { lvs --noheadings --units m --nosuffix -o lv_size vg_lab/lv_data 2>/dev/null | awk '{printf "%d", $1}'; }
# Size of the filesystem on lv_data in MiB: from df if it's mounted, else
# from the superblock.
fs_mib() {
	local dev=/dev/mapper/vg_lab-lv_data m b
	m=$(findmnt -rn -o TARGET -S "$dev" | head -n1)
	if [ -n "$m" ]; then df -BM --output=size "$m" | tail -n1 | tr -dc 0-9; return; fi
	b=$(blkid -p -s FSSIZE -o value "$dev" 2>/dev/null)
	if [ -z "$b" ] && [ "$(blkid -s TYPE -o value "$dev")" = ext4 ]; then
		b=$(dumpe2fs -h "$dev" 2>/dev/null | awk -F: '/^Block count/ {c = $2} /^Block size/ {s = $2} END {print c * s}')
	fi
	[ -n "$b" ] && echo $((b / 1048576))
}
# New swap files, with their sizes in bytes.
new_swapfiles() {
	swapon --show=NAME,TYPE,SIZE --bytes --noheadings | awk '$2 == "file" {print $1, $3}' |
		while read -r f s; do grep -qxF "$f" "$LAB_STATE/old-swaps" || echo "$f $s"; done
}

task 1 "vg_lab/lv_data on /dev/loop40, grown with its filesystem to 1.5 GiB"
need "/dev/loop40 is a physical volume in vg_lab" '[ "$(pvs --noheadings -o vg_name /dev/loop40 2>/dev/null | tr -d " ")" = vg_lab ]'
need "logical volume vg_lab/lv_data exists" lvs vg_lab/lv_data
need "lv_data holds a filesystem" '[ -n "$(blkid -s TYPE -o value /dev/mapper/vg_lab-lv_data)" ]'
need "lv_data is about 1.5 GiB (1 GiB + 500 MiB)" '[ "$(lv_mib)" -ge 1500 ] && [ "$(lv_mib)" -le 1560 ]'
need "the filesystem has grown with it" '[ "$(fs_mib)" -ge 1400 ]'

task 2 "A 512 MiB swap file is on"
need "a swap file is on (swapon --show)" '[ -n "$(new_swapfiles)" ]'
need "the swap file is 512 MiB" 'new_swapfiles | awk "\$2 >= 530000000 && \$2 <= 540100000 {ok = 1} END {exit !ok}"'
