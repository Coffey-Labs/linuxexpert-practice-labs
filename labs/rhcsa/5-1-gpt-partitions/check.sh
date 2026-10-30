LVM_GUID=E6D6D379-F507-44C2-A23C-238F2A3DF928
# part DISK N FIELD: a field (start, size, type, uuid) of partition N from
# sfdisk --dump, read from the disk itself.
part() { sfdisk --dump "$1" 2>/dev/null | grep "^$1p$2 " | grep -oE "(^|[ ,])$3= *[^,]+" | sed -E "s/^[ ,]*$3= *//" | tr a-z A-Z; }
nparts() { sfdisk --dump "$1" 2>/dev/null | grep -c "^$1p[0-9]"; }
# Size in MiB of partition N (512-byte sectors).
mib() { local s; s=$(part "$1" "$2" size); [ -n "$s" ] && echo $((s / 2048)); }
about() { [ -n "$1" ] && [ "$1" -ge $(($2 - 1)) ] && [ "$1" -le $(($2 + 1)) ]; }

task 1 "/dev/loop40: GPT with a 500 MiB partition"
need "/dev/loop40 has a GPT partition table" 'sfdisk --dump /dev/loop40 | grep -qx "label: gpt"'
need "/dev/loop40p1 is 500 MiB" 'about "$(mib /dev/loop40 1)" 500'

task 2 "/dev/loop40p2: 300 MiB, Linux LVM"
need "/dev/loop40p1 is still 500 MiB" 'about "$(mib /dev/loop40 1)" 500'
need "/dev/loop40p2 is 300 MiB" 'about "$(mib /dev/loop40 2)" 300'
need "/dev/loop40p2 has the type Linux LVM" '[ "$(part /dev/loop40 2 type)" = $LVM_GUID ]'
need "the kernel knows the partitions (lsblk shows loop40p2)" '[ -b /dev/loop40p2 ]'

task 3 "/dev/loop41: second partition deleted, first one unchanged"
need "/dev/loop41 has only one partition" '[ "$(nparts /dev/loop41)" = 1 ]'
need "/dev/loop41p1 is unchanged" '[ "$(sfdisk --dump /dev/loop41 | grep "^/dev/loop41p1 ")" = "$(cat "$LAB_STATE/loop41p1")" ]'
need "the kernel knows (lsblk shows no loop41p2)" '[ ! -e /dev/loop41p2 ]'
