# Using Linux Terminal 2.2: Partitions and filesystems

A GPT partition with an ext4 filesystem mounted at boot by UUID, getting a
deleted partition back, and a read-only filesystem check.

## Before you start

Work as root (`sudo -i`), and write answers to the files in
`/root/lab-answers/`. The lab adds a blank 2 GiB spare disk,
`/dev/loop40`, which stays attached across reboots; its first partition is
`/dev/loop40p1` (the guide's `/dev/vdb` and `/dev/vdb1`). It saves
`/etc/fstab` and puts it back on reset, which also removes the disk.

## Tasks

1. Give `/dev/loop40` a GPT partition table with one 1 GiB partition, make
   an ext4 filesystem labelled `data` on it, and mount it at `/mnt/data` at
   every boot, by UUID. `findmnt --verify` reports no errors or warnings.
2. Save a file `/mnt/data/keep.txt` containing `keep me`. Unmount the
   filesystem, write its partition's start sector to
   `/root/lab-answers/2`, delete the partition with fdisk, then recreate it
   so that `keep.txt` comes back unchanged. Mount it again.
3. Check the filesystem fully while it's unmounted, without letting fsck
   change anything, and save fsck's output in `/root/lab-answers/3`.

## Hints

- `fdisk /dev/loop40` (`g`, `n`, `+1G`, `w`) or `parted`; `mkfs.ext4 -L`;
  `blkid` for the UUID; `systemctl daemon-reload` after editing fstab, then
  `mount -a`.
- `fdisk -l /dev/loop40` shows the start; recreate with the same start and
  answer **N** to "remove the signature". `blkid` shows the same UUID.
- `fsck -fn /dev/loop40p1 >/root/lab-answers/3 2>&1`.
