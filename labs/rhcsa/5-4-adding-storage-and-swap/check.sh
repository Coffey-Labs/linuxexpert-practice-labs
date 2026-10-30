# Swap devices in /etc/fstab, resolved to device paths.
fstab_swaps() {
	local s
	findmnt --fstab -n -t swap -o SOURCE 2>/dev/null | while read -r s; do
		case $s in
		UUID=* | LABEL=* | PARTUUID=* | PARTLABEL=*) blkid -t "$s" -o device 2>/dev/null ;;
		*) echo "$s" ;;
		esac
	done | xargs -r -n1 readlink -f
}
in_fstab() { fstab_swaps | grep -qxF "$(readlink -f "$1")"; }
active_swap() { swapon --show=NAME --noheadings | xargs -r -n1 readlink -f | grep -qxF "$(readlink -f "$1")"; }
# The swap partition on loop40, and the new swap LV in vglab.
swap_part() { local p; for p in /dev/loop40p[2-9]; do [ "$(blkid -s TYPE -o value "$p" 2>/dev/null)" = swap ] && { echo "$p"; return; }; done; }
swap_lv() { local l; for l in $(lvs --noheadings -o lv_path vglab 2>/dev/null); do [ "${l##*/}" = oldswap ] && continue; [ "$(blkid -s TYPE -o value "$l" 2>/dev/null)" = swap ] && { echo "$l"; return; }; done; }
mib() { echo $(($(blockdev --getsize64 "$1") / 1048576)); }
about() { [ -n "$1" ] && [ "$1" -ge $(($2 - 2)) ] && [ "$1" -le $(($2 + 2)) ]; }
data_ok() {
	local f sum
	while read -r sum f; do
		[ "$(debugfs -R "cat /$f" /dev/loop40p1 2>/dev/null | sha256sum | cut -d" " -f1)" = "$sum" ] || return 1
	done <"$LAB_STATE/data.sha"
}

task 1 "A 512 MiB swap partition on /dev/loop40, active at boot"
need "/dev/loop40 has a second partition with swap on it" '[ -n "$(swap_part)" ]'
need "the swap partition is 512 MiB" 'about "$(mib "$(swap_part)")" 512'
need "it's active (swapon --show)" 'active_swap "$(swap_part)"'
need "it's in /etc/fstab" 'in_fstab "$(swap_part)"'
need "the first partition is unchanged" '[ "$(sfdisk --dump /dev/loop40 | grep "^/dev/loop40p1 ")" = "$(cat "$LAB_STATE/p1")" ] && [ "$(blkid -s UUID -o value /dev/loop40p1)" = "$(cat "$LAB_STATE/p1-uuid")" ]'
need "its data is unchanged" data_ok

task 2 "A 256 MiB swap LV in vglab, active at boot"
need "vglab has a new logical volume with swap on it" '[ -n "$(swap_lv)" ]'
need "it's 256 MiB" 'about "$(lvs --noheadings --units m --nosuffix -o lv_size "$(swap_lv)" | cut -d. -f1 | tr -d " ")" 256'
need "it's active (swapon --show)" 'active_swap "$(swap_lv)"'
need "it's in /etc/fstab" 'in_fstab "$(swap_lv)"'

task 3 "oldswap removed cleanly"
need "oldswap isn't active" '! swapon --show=NAME --noheadings | grep -q oldswap && ! swapon --show=NAME --noheadings | xargs -r -n1 readlink -f | grep -qxF "$(readlink -f /dev/vglab/oldswap 2>/dev/null || echo none)"'
need "the LV oldswap is gone" '! lvs vglab/oldswap'
need "no /etc/fstab line names it" '! grep -Ev "^[[:space:]]*#" /etc/fstab | grep -Eq "oldswap|$(cat "$LAB_STATE/oldswap-uuid")"'
need "this boot has no Timed out waiting for device error" '! journalctl -q -b -p err | grep -q "Timed out waiting for device"'
