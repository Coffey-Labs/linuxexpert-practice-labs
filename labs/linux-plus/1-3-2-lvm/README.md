# Linux+ 1.3.2: Logical volume management

A volume group with two logical volumes, growing one while it's mounted, and
emptying a disk to take it out of the group.

## Before you start

The lab adds two empty 1 GiB spare disks, `/dev/loop40` and `/dev/loop41`
(the chapter's `vdb` and `vdc`). They come back at every boot. Nothing here
is mounted at boot, so do the tasks in one go, without a reboot, and run
`le-lab check` before you clean up.

## Tasks

1. Make both disks physical volumes in a volume group `vglab`. Create a
   600 MiB logical volume `one` and a logical volume `two` from all the rest
   of the space. Put ext4 on `one` and mount it at `/mnt/one`.
2. Remove `two`, and grow `one` and its filesystem by 300 MiB while it's
   mounted.
3. Move everything off `/dev/loop40` and take it out of `vglab`.

When `le-lab check` passes, clean up as the chapter shows (unmount, remove
the volume group and the physical volumes), or leave it to `le-lab reset`.

## Hints

- `pvcreate`, `vgcreate`, `lvcreate -n -L`, `lvcreate -l 100%FREE`,
  `mkfs.ext4`; `pvs`, `vgs`, `lvs`.
- `lvremove`, `lvextend -r -L +300M`; `df -h /mnt/one`.
- `pvs -o+pv_used`, `pvmove`, `vgreduce`.
