# LFCS 3.1: LVM

Building a volume group, growing a logical volume while it's in use,
snapshots, swapping out a disk, and shrinking ext4.

## Before you start

The lab adds three empty 2 GiB spare disks: `/dev/loop40`, `/dev/loop41`
and `/dev/loop42`. They come back at every boot, before filesystems are
mounted, so `/etc/fstab` lines and volume groups on them keep working.

## Tasks

1. Create volume group `vg_lab` from `/dev/loop40` and `/dev/loop41`, and a
   1 GiB logical volume `lv_data` in it with an XFS filesystem, mounted at
   `/data` at every boot.
2. Grow `lv_data` and its filesystem by 500 MiB while it's mounted.
3. Write `version 1` to `/data/notes.txt`. Snapshot `lv_data` as
   `lv_data_snap` (200 MiB is plenty), then change `/data/notes.txt` to
   `version 2` and read the old version from the snapshot (mount it
   read-only at `/mnt/snap`). Keep the snapshot.
4. Add the third disk, `/dev/loop42`, to `vg_lab`, then remove the first
   disk, `/dev/loop40`, from it without losing data.
5. Create a 1 GiB logical volume `lv_files` in `vg_lab` with an ext4
   filesystem, mounted at `/files` at every boot. Copy `/etc/services` into
   it, then shrink the volume and its filesystem to 600 MiB.

## Hints

- `pvcreate`, `vgcreate`, `lvcreate -n -L`, `mkfs.xfs`, a line in
  `/etc/fstab`, then `systemctl daemon-reload` and `mount -a`.
- `lvextend -r`; `df -h /data` before and after.
- `lvcreate -s`; an XFS snapshot needs `mount -o ro,nouuid`.
- `vgextend`, `pvmove`, `vgreduce`, `pvremove`; `pvs` and `lvs -o +devices`.
- ext4 shrinks only unmounted: `umount`, then `lvreduce -r`.
