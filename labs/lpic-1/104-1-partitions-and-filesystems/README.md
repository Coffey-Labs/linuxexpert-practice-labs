# LPIC-1 104.1: Creating partitions and filesystems

Partitioning with `fdisk` and `parted`, ext4 and XFS with labels, a swap
partition, wiping a disk, and Btrfs subvolumes and snapshots.

## Before you start

The lab adds two empty 4 GiB spare disks, `/dev/loop40` and `/dev/loop41`
(the chapter's `/dev/sdb` and `/dev/sdc`). Their partitions show up as
`/dev/loop40p1` and so on. It installs the Btrfs tools if they're missing.
Task 5 needs Btrfs, which AlmaLinux 10 and Ubuntu have but RHEL and Rocky
Linux leave out, so the lab won't start there. Swap you turn on by hand
is off again after a reboot, so check before you reboot.

## Tasks

1. Partition `/dev/loop40` as GPT with `fdisk`: a 1 GiB partition, a
   512 MiB partition with the swap type, and the rest. Print the table
   before writing.
2. Put ext4 on the first partition and XFS on the third, each with a
   label. Run `lsblk -f` to see them.
3. Turn the second partition into swap, enable it, and check with
   `swapon --show` and `free -h`.
4. Give `/dev/loop41` a GPT table and one partition with `parted`, and
   notice that nothing asks you to confirm a write. Then clear it with
   `wipefs -a /dev/loop41`. Check it yourself: `wipefs /dev/loop41` lists
   nothing afterwards.
5. Make a Btrfs filesystem on `/dev/loop41`, create a subvolume, write a
   file, snapshot the subvolume, delete the file, and find it again in
   the snapshot.

## Hints

- In `fdisk`: `g` (new GPT table), `n` (sizes as `+1G`, `+512M`), `t`
  (type `swap` or `19`), `p`, `w`.
- `mkfs.ext4 -L`, `mkfs.xfs -L`; `lsblk -f`.
- `mkswap`, `swapon`, `swapon --show`, `free -h`.
- `parted -s /dev/loop41 mklabel gpt mkpart one 1MiB 100%`; `wipefs -a`.
- `mkfs.btrfs`, mount it, `btrfs subvolume create`, `btrfs subvolume
  snapshot`, `btrfs subvolume list`.
