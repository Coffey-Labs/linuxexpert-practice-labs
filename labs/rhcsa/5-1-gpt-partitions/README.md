# RHCSA 5.1: GPT partitions

A GPT partition table, partitions of a given size and type, and deleting
a partition.

## Before you start

The lab adds two 1 GiB spare disks. They're image files under
`/var/lib/le-lab/disks/`, attached again at every boot.

- `/dev/loop40` is empty: it stands in for the guide's `/dev/vdb`, so its
  partitions are `/dev/loop40p1` and `/dev/loop40p2`.
- `/dev/loop41` already has a GPT table with a 500 MiB partition and a
  300 MiB Linux LVM partition, as tasks 1 and 2 leave `/dev/loop40`.
  Task 3 works on it, so the first two tasks' results can stay.

## Tasks

1. Give `/dev/loop40` a GPT partition table and create a 500 MiB
   partition on it.
2. With fdisk, add a second partition of 300 MiB of type Linux LVM beside
   the first one.
3. Delete the second partition of `/dev/loop41` again, leaving its first
   partition as it is.

## Hints

- `parted /dev/loop40 mklabel gpt`, `mkpart`, `print`; or `gdisk`.
- In `fdisk`: `n`, size `+300M`, `t`, type `lvm` (or its number from
  `L`), `w`. `fdisk -l /dev/loop40`, `lsblk /dev/loop40`.
- `fdisk`: `d`, `2`, `w`; or `parted /dev/loop41 rm 2`.
