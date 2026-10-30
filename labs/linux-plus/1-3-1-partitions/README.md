# Linux+ 1.3.1: Disks and partitions

GPT partition tables with fdisk and with parted in script mode, and growing
a partition into free space.

## Before you start

The lab adds three empty 2 GiB spare disks: `/dev/loop40`, `/dev/loop41`
and `/dev/loop42`. Their partitions show up as `/dev/loop40p1` and so on.
They come back at every boot. Each task has a disk of its own, so that the
check can see all three results.

## Tasks

1. On `/dev/loop40`, make a GPT partition table with two partitions using
   fdisk: the first 500 MiB, the second filling the rest of the disk.
2. On `/dev/loop41`, do the same with parted in script mode (`parted -s`),
   naming the partitions `one` and `two`.
3. On `/dev/loop42`, make the same two partitions, then delete partition 2
   and grow partition 1 into the free space with `growpart`.

## Hints

- `lsblk` first, to be sure you're on the right disk.
- In fdisk: `g` (new GPT table), `n` (new partition, size `+500M`), `n`
  again (accept the defaults for the rest), `p`, `w`.
- `parted -s DISK mklabel gpt mkpart one 1MiB 500MiB mkpart two 500MiB 100%`;
  `parted DISK print`.
- `parted -s DISK rm 2`, then `growpart DISK 1` (in `cloud-utils-growpart`
  on the RHEL family, `cloud-guest-utils` on Ubuntu).
