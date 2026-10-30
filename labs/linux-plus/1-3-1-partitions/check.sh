# parted's machine-readable listing in MiB: NUMBER:START:END:SIZE:FS:NAME:FLAGS
parts() { parted -m -s "$1" unit MiB print 2>/dev/null | grep -E '^[0-9]+:' | tr -d 'MiB;'; }
label() { parted -m -s "$1" print 2>/dev/null | awk -F: 'NR == 2 {print $6}'; }
# field DISK PART N: field N of partition PART, whole MiB.
field() { parts "$1" | awk -F: -v p="$2" -v n="$3" '$1 == p {printf "%d", $n}'; }
count() { parts "$1" | wc -l; }
between() { [ -n "$1" ] && [ "$1" -ge "$2" ] && [ "$1" -le "$3" ]; }

task 1 "loop40: GPT, 500 MiB and the rest, with fdisk"
need "/dev/loop40 has a GPT partition table" '[ "$(label /dev/loop40)" = gpt ]'
need "/dev/loop40 has two partitions" '[ "$(count /dev/loop40)" = 2 ]'
need "partition 1 is 500 MiB" 'between "$(field /dev/loop40 1 4)" 495 505'
need "partition 2 fills the rest of the disk" 'between "$(field /dev/loop40 2 3)" 2040 2048 && between "$(field /dev/loop40 2 4)" 1500 1550'

task 2 "loop41: GPT with partitions one and two, with parted"
need "/dev/loop41 has a GPT partition table" '[ "$(label /dev/loop41)" = gpt ]'
need "/dev/loop41 has two partitions" '[ "$(count /dev/loop41)" = 2 ]'
need "they're named one and two" '[ "$(parts /dev/loop41 | cut -d: -f6 | paste -sd,)" = one,two ]'
need "partition 1 is about 500 MiB" 'between "$(field /dev/loop41 1 4)" 490 505'
need "partition 2 fills the rest of the disk" 'between "$(field /dev/loop41 2 3)" 2040 2048 && between "$(field /dev/loop41 2 4)" 1500 1560'

task 3 "loop42: partition 2 deleted, partition 1 grown into the space"
need "/dev/loop42 has a GPT partition table" '[ "$(label /dev/loop42)" = gpt ]'
need "/dev/loop42 has only partition 1" '[ "$(parts /dev/loop42 | cut -d: -f1 | paste -sd,)" = 1 ]'
need "partition 1 starts where it did (near the start of the disk)" 'between "$(field /dev/loop42 1 2)" 0 2'
need "partition 1 fills the disk" 'between "$(field /dev/loop42 1 3)" 2040 2048'
need "the kernel sees the grown partition" 'between "$(( $(blockdev --getsize64 /dev/loop42p1 2>/dev/null || echo 0) / 1048576 ))" 2030 2048'
