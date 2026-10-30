# RHCSA 5.2: LVM physical volumes, volume groups and logical volumes

A volume group with a chosen extent size, a logical volume sized in
extents, growing a volume group, and taking LVM apart cleanly.

## Before you start

The lab adds two 1 GiB spare disks. They're image files under
`/var/lib/le-lab/disks/`, attached again at every boot.

- `/dev/loop40` has two empty partitions: `/dev/loop40p1` (600 MiB) and
  `/dev/loop40p2` (300 MiB). Tasks 1 and 2 use them.
- `/dev/loop41` has two partitions that are physical volumes of a volume
  group `vgold`, with logical volumes `lvone` and `lvtwo`, as tasks 1 and
  2 leave `vgdata`. Task 3 takes it apart, so the first two tasks' results
  can stay.

## Tasks

1. Create a volume group `vgdata` with 8 MiB extents on `/dev/loop40p1`,
   and a logical volume `lvdata` of exactly 50 extents.
2. Add `/dev/loop40p2` to `vgdata`, and create a logical volume `lvrest`
   that uses all the space left.
3. Remove `lvone`, `lvtwo`, the volume group `vgold` and both its
   physical volumes (`/dev/loop41p1` and `/dev/loop41p2`) cleanly.

## Hints

- `pvcreate`, `vgcreate -s 8M`, `lvcreate -l 50 -n`; `vgdisplay`,
  `lvdisplay` (`Current LE`, `LV Size`).
- `vgextend`, `lvcreate -l 100%FREE`; `vgs vgdata` shows `#PV` and
  `VFree`.
- `lvremove`, `vgremove`, `pvremove`; `pvs`, `vgs`, `lvs`, `lsblk -f`.
