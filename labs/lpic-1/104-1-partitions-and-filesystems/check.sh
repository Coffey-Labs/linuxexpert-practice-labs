sectors() { cat "/sys/class/block/$1/$2" 2>/dev/null || echo 0; }
mib() { echo $(( $(sectors "$1" size) / 2048 )); }
ptype() { lsblk -dno PARTTYPE "/dev/$1" 2>/dev/null | tr 'A-Z' 'a-z' | tr -d ' '; }
SWAP_GUID=0657fd6d-a4ab-43c4-84e5-0933c84b4f4f
# A snapshot on the Btrfs filesystem of /dev/loop41 holds a file that its
# source subvolume no longer has.
btrfs_ok() {
	local m rc=1 line uuid puuid path src f
	m=$(mktemp -d)
	mount -o ro,subvolid=5 /dev/loop41 "$m" 2>/dev/null || { rmdir "$m"; return 1; }
	declare -A byuuid
	while read -r line; do
		uuid=$(sed -n 's/.* uuid \([^ ]*\) .*/\1/p' <<<"$line")
		path=$(sed -n 's/.* path \(.*\)$/\1/p' <<<"$line")
		byuuid[$uuid]=${path#<FS_TREE>/}
	done < <(btrfs subvolume list -u "$m" 2>/dev/null)
	while read -r line; do
		puuid=$(sed -n 's/.* parent_uuid \([^ ]*\) .*/\1/p' <<<"$line")
		path=$(sed -n 's/.* path \(.*\)$/\1/p' <<<"$line"); path=${path#<FS_TREE>/}
		src=${byuuid[$puuid]:-}
		[ -n "$src" ] || continue
		while read -r f; do
			[ -e "$m/$src/$f" ] || { rc=0; break 2; }
		done < <(cd "$m/$path" && find . -xdev -type f)
	done < <(btrfs subvolume list -u -q "$m" 2>/dev/null)
	umount "$m"; rmdir "$m"
	return $rc
}

task 1 "GPT on /dev/loop40: 1 GiB, 512 MiB swap type, and the rest"
need "/dev/loop40 has a GPT partition table" '[ "$(blkid -p -s PTTYPE -o value /dev/loop40)" = gpt ]'
need "/dev/loop40p1 is 1 GiB" '[ "$(mib loop40p1)" -ge 1000 ] && [ "$(mib loop40p1)" -le 1030 ]'
need "/dev/loop40p2 is 512 MiB" '[ "$(mib loop40p2)" -ge 500 ] && [ "$(mib loop40p2)" -le 520 ]'
need "/dev/loop40p2 has the Linux swap type" '[ "$(ptype loop40p2)" = $SWAP_GUID ]'
need "/dev/loop40p3 takes the rest of the disk" '[ "$(mib loop40p3)" -ge 2400 ]'

task 2 "ext4 and XFS, each with a label"
need "/dev/loop40p1 holds ext4" '[ "$(blkid -s TYPE -o value /dev/loop40p1)" = ext4 ]'
need "the ext4 filesystem has a label" '[ -n "$(blkid -s LABEL -o value /dev/loop40p1)" ]'
need "/dev/loop40p3 holds XFS" '[ "$(blkid -s TYPE -o value /dev/loop40p3)" = xfs ]'
need "the XFS filesystem has a label" '[ -n "$(blkid -s LABEL -o value /dev/loop40p3)" ]'

task 3 "Swap on /dev/loop40p2"
need "/dev/loop40p2 is swap" '[ "$(blkid -s TYPE -o value /dev/loop40p2)" = swap ]'
need "it's in use (swapon --show)" 'swapon --show=NAME --noheadings | grep -qx /dev/loop40p2'

task 4 "A GPT table made with parted, then wiped" self

task 5 "Btrfs: a subvolume, a snapshot, and a file found again in it"
need "/dev/loop41 holds Btrfs" '[ "$(blkid -s TYPE -o value /dev/loop41)" = btrfs ]'
need "a snapshot holds a file deleted from its subvolume" btrfs_ok
