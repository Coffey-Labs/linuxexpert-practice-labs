# LFCS 3.3: Filesystems

Partitioning a disk, XFS and ext4 filesystems, labels and UUIDs, repairing
a damaged filesystem, and growing a partition.

## Before you start

The lab adds an empty 3 GiB spare disk, `/dev/loop40`. Its partitions show
up as `/dev/loop40p1`, `/dev/loop40p2` and so on. It comes back at every
boot, before filesystems are mounted, so `/etc/fstab` lines for it keep
working. The disk is a file, `/var/lib/le-lab/disks/disk0.img`, which
task 4 grows the way a hypervisor would.

## Tasks

1. Create a GPT partition table on `/dev/loop40` and a 2 GiB partition,
   `/dev/loop40p1`, with an XFS filesystem labeled `backup`, mounted at
   `/backup` by label at every boot.
2. Create a second partition, `/dev/loop40p2`, filling the rest of the
   disk, with an ext4 filesystem. Reserve only 1% of it for root, and mount
   it at `/data` by UUID at every boot.
3. Damage the ext4 filesystem while it's unmounted, with
   `sudo dd if=/dev/zero of=/dev/loop40p2 bs=4096 seek=10 count=50`, then
   repair it.
4. Grow the disk to 4 GiB: `sudo truncate -s 4G
   /var/lib/le-lab/disks/disk0.img`, then `sudo losetup -c /dev/loop40` so
   the system sees the new size. Then grow the last partition (the ext4 one)
   and its filesystem to fill the disk, while it's mounted.

## Hints

- `fdisk`, `gdisk` or `parted`; `lsblk`, `partprobe`.
- `mkfs.xfs -L`, `mkfs.ext4`, `tune2fs -m` and `tune2fs -l`.
- `blkid`, `lsblk -f`; `LABEL=` and `UUID=` in `/etc/fstab`;
  `findmnt --verify`.
- `umount`, `e2fsck -f`; `e2fsck -fn` only reports.
- `growpart` (or `parted resizepart`), then `resize2fs`; `df -h`.
