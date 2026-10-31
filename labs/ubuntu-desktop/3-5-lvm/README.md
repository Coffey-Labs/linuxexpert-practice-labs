# Ubuntu Desktop 3.5: LVM volumes, filesystems and snapshots

A volume group on a spare disk, an ext4 logical volume mounted at boot,
growing it onto a second disk while it's mounted, and getting a deleted
file back by merging a snapshot.

## Before you start

The lab adds two empty spare disks: `/dev/loop40` (1 GiB, the first) and
`/dev/loop41` (2 GiB, the second). They come back at every boot. The LVM
tools are installed.

## Tasks

1. Make a volume group `vg1` from the first spare disk and an 800 MiB
   logical volume `home2` with ext4, mounted at `/mnt/home2` at every
   boot.
2. Grow `home2` by 1.5 GiB, adding the second disk to the group first if
   needed, without unmounting it.
3. Create a file `/mnt/home2/notes.txt`, snapshot `home2`, delete
   `notes.txt`, and get it back by merging the snapshot.

## Hints

- `pvcreate`, `vgcreate`, `lvcreate -L 800M -n`, `mkfs.ext4`; an
  `/etc/fstab` line for `/dev/mapper/vg1-home2` (or its UUID), then
  `systemctl daemon-reload` and `mount -a`.
- `vgs vg1` shows the free space; `vgextend`, then `lvextend -r -L +1.5G`
  grows the filesystem too. `df -h /mnt/home2` should show about 2.3G.
- `lvcreate -s -L 200M -n NAME vg1/home2`; unmount, `lvconvert --merge
  vg1/NAME`, mount again. `lvs vg1` no longer lists the snapshot.
