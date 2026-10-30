# RHCSA 6.1: VFAT, ext4 and XFS

Making the three file system types, mounting VFAT for a normal user, and
unmounting a file system that's in use.

## Before you start

The lab adds three empty spare disks: `/dev/loop40` (256 MiB),
`/dev/loop41` (256 MiB) and `/dev/loop42` (512 MiB). They come back at
every boot, before file systems are mounted, so `/etc/fstab` lines for them
keep working. It also creates user `student` (password `Lab-Pass-1`) if
there isn't one.

## Tasks

1. Create a VFAT file system on `/dev/loop40`, ext4 on `/dev/loop41` and
   XFS on `/dev/loop42`, and mount them at `/mnt/fat`, `/mnt/ext` and
   `/mnt/xfs`. As root, create a file in each.
2. Mount the VFAT file system so that user `student` owns everything on it,
   and make that permanent: after a reboot, `touch /mnt/fat/test` works as
   `student`.
3. `cd` into `/mnt/xfs` in one shell and try to unmount it from another.
   Find out which program keeps it busy and write its name to
   `/root/lab-answers/3`. Then leave the directory and unmount `/mnt/xfs`.

## Hints

- `mkfs.vfat` (package `dosfstools`), `mkfs.ext4`, `mkfs.xfs`; `mkdir -p`,
  `mount`, `lsblk -f`.
- `uid=` and `gid=` mount options for VFAT; a line in `/etc/fstab` (by
  `UUID=`), then `systemctl daemon-reload` and `mount -a`. `chown` doesn't
  work on VFAT.
- `fuser -vm /mnt/xfs`, or `lsof /mnt/xfs`; `findmnt /mnt/xfs`.
- The check mounts `/dev/loop42` for a moment to look for your file if it
  isn't mounted. Mount `/mnt/ext` at every boot too if you reboot for
  task 2, or mount it again afterwards.
