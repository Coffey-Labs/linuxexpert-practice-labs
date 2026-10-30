# LPIC-1 102.1: Designing a disk layout

Building LVM on a spare disk, growing a logical volume and its filesystem
in one step, and adding a swap file.

## Before you start

The lab adds an empty 2 GiB spare disk, `/dev/loop40`. It comes back at
every boot, before filesystems are mounted. Before you start, look at the
VM's own layout with `lsblk -f` and `findmnt`, and work out why each
filesystem is where it is.

## Tasks

1. On `/dev/loop40`, make a physical volume, a volume group `vg_lab` and a
   1 GiB logical volume `lv_data`, and put a filesystem on it. Then grow
   the logical volume and its filesystem by 500 MiB in one step with
   `lvextend -r`.
2. Add a 512 MiB swap file, turn it on, and check it with `swapon --show`.

## Hints

- `pvcreate`, `vgcreate`, `lvcreate -n lv_data -L 1G vg_lab`,
  `mkfs.ext4` or `mkfs.xfs`; `lvs`, `lsblk -f`.
- `lvextend -r -L +500M`. XFS grows only while it's mounted; ext4 grows
  either way.
- `fallocate -l 512M` (or `dd`), `chmod 600`, `mkswap`, `swapon`; a line in
  `/etc/fstab` keeps it on after a reboot.
