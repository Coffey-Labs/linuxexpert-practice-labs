# RHCSA 6.4: Extending logical volumes

Growing a mounted XFS volume, growing a volume and its file system in two
steps, and adding a disk to a full volume group.

## Before you start

The lab adds two spare disks, `/dev/loop40` (2 GiB) and `/dev/loop41`
(1 GiB, empty). They come back at every boot, before file systems are
mounted. On `/dev/loop40` it creates volume group `vg_lab` with two
logical volumes, both mounted at every boot (lines in `/etc/fstab`):

- `lv_data`, 500 MiB, XFS, at `/data`;
- `lv_logs`, 300 MiB, ext4, at `/logs`.

Each holds a file `keep.txt` that must survive.

## Tasks

1. Grow `lv_data` and its file system by 200 MiB without unmounting it.
2. Grow `lv_logs` by 100 MiB without `-r`, and see what `df -h /logs`
   says. Then grow the file system to match.
3. Grow `lv_data` to fill all of `vg_lab`'s free space. Then grow it by
   another 200 MiB by adding `/dev/loop41` (or a partition on it) to
   `vg_lab`.

## Hints

- `lvextend -r -L +200M`; `lvs`, `df -h`.
- `lvextend -L +100M`, then `resize2fs` (ext4) or `xfs_growfs` (XFS).
- `lvextend -l +100%FREE`; `vgs` shows `VFree`. `pvcreate` (or a partition
  with `fdisk` or `parted`), `vgextend`; `pvs`.
