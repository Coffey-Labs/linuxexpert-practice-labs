nodes_wait 60 || true
# ans CMD: run CMD as greg in his project directory.
ans() { timeout 300 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
OUT=$LAB_STATE/check.out
# mnt PATH FIELD: a field of what's mounted at PATH (SOURCE, FSTYPE).
mnt() { findmnt -n -o "$2" "$1" 2>/dev/null; }
# in_fstab PATH: /etc/fstab mounts something at PATH.
in_fstab() { awk -v m="$1" '$1 !~ /^#/ && $2 == m' /etc/fstab | grep -q .; }
# mib DEV: the size of DEV in MiB.
mib() { echo $(( $(lsblk -bdno SIZE "$1") / 1048576 )); }
# The size the logical volume should have: 1500 MiB where research has
# room for it, 800 MiB where it doesn't.
VG=$(vgs --noheadings --units m --nosuffix -o vg_size research 2>/dev/null | awk '{printf "%d", $1}')
WANT=800; [ "${VG:-0}" -ge 1500 ] && WANT=1500

task 1 "A 1 GiB XFS partition on /dev/loop40, mounted at /srv/archive persistently"
need "/dev/loop40p1 is about 1 GiB" '[ -b /dev/loop40p1 ] && s=$(mib /dev/loop40p1) && [ "$s" -ge 1000 ] && [ "$s" -le 1030 ]'
need "/dev/loop40p1 is mounted at /srv/archive" '[ "$(mnt /srv/archive SOURCE)" = /dev/loop40p1 ]'
need "/srv/archive is XFS" '[ "$(mnt /srv/archive FSTYPE)" = xfs ]'
need "/etc/fstab mounts /srv/archive" 'in_fstab /srv/archive'

task 2 "Volume group research, and lv.yml: 1500 MiB or 800 MiB, or a message"
need "volume group research is on /dev/loop41" 'pvs --noheadings -o vg_name /dev/loop41 2>/dev/null | grep -qw research'
need "research/data is $WANT MiB" '[ -b /dev/research/data ] && [ "$(mib /dev/research/data)" = "$WANT" ]'
need "research/data is mounted at /mnt/data as ext4" '[ "$(mnt /mnt/data FSTYPE)" = ext4 ] && [ "$(readlink -f "$(mnt /mnt/data SOURCE)")" = "$(readlink -f /dev/research/data)" ]'
need "/etc/fstab mounts /mnt/data" 'in_fstab /mnt/data'
need "/home/greg/ansible/lv.yml exists" '[ -f /home/greg/ansible/lv.yml ]'
need "ansible-playbook lv.yml runs without failures and says \"Volume group does not exist\" for node1" \
	'ans ansible-playbook lv.yml >"$OUT"; grep -Eq "^node1 +: ok=.* failed=0" "$OUT" && grep -Eq "^localhost +: ok=.* failed=0" "$OUT" &&
	grep -A1 "^ok: \[node1\] => {" "$OUT" | grep -q "Volume group does not exist"'

task 3 "A 1 GiB XFS logical volume at /srv/web, from the storage system role"
need "/srv/web is mounted from a logical volume" '[ "$(lsblk -no TYPE "$(mnt /srv/web SOURCE)" 2>/dev/null)" = lvm ]'
need "/srv/web is XFS" '[ "$(mnt /srv/web FSTYPE)" = xfs ]'
need "its logical volume is 1 GiB" '[ "$(mib "$(mnt /srv/web SOURCE)")" = 1024 ]'
need "its volume group is on /dev/loop42" 'lvs --noheadings -o devices "$(mnt /srv/web SOURCE)" 2>/dev/null | grep -q /dev/loop42'
need "/etc/fstab mounts /srv/web" 'in_fstab /srv/web'
rm -f "$OUT"
