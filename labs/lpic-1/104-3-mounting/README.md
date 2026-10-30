# LPIC-1 104.3: Mounting and unmounting filesystems

Mounting by hand, finding what keeps a filesystem busy, mounting at boot
by UUID, systemd mount units, user mounts, and remounting read-only.

## Before you start

The lab adds two spare disks, each with an ext4 filesystem that isn't
mounted: `/dev/loop40p1` (1 GiB, standing in for the one from 104.1) and
`/dev/loop41` (256 MiB, labeled `stick`, standing in for a USB stick). They
come back at every boot, before filesystems are mounted. It also creates
user `uma` (password `Lab-Pass-1`). Write answers to the files in
`/root/lab-answers/`.

## Tasks

1. Mount `/dev/loop40p1` by hand on `/mnt/data`, create a file in it, `cd`
   into it in another terminal, and try to unmount. Find the blocker with
   `fuser -vm`.
2. Add it to `/etc/fstab` by UUID, still at `/mnt/data`, check with
   `findmnt --verify` and `mount -a`, and reboot to prove it comes back.
3. Find the mount unit systemd made for it, and read it with `systemctl
   cat`. Write the unit's name to `/root/lab-answers/3`.
4. Add a `noauto,users` line for `/dev/loop41` at `/mnt/stick`, and mount
   and unmount it as `uma`.
5. Remount `/mnt/data` read-only with `mount -o remount,ro`, try to write
   to it, and remount it read-write. Check it yourself: the write fails
   with "Read-only file system" in between.

## Hints

- `mount`, `umount`, `fuser -vm /mnt/data`; `lsof /mnt/data` works too.
- `blkid`, `UUID=... /mnt/data ext4 defaults 0 2`; `systemctl
  daemon-reload` after editing fstab.
- `systemctl list-units --type=mount`, `systemd-escape -p --suffix=mount
  /mnt/data`.
- `LABEL=stick /mnt/stick ext4 noauto,users 0 0`; then `su - uma` and
  `mount /mnt/stick`.
- `touch /mnt/data/x` while it's read-only.
