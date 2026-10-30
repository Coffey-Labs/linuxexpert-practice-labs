# RHCSA 5.4: Adding storage and swap without data loss

A swap partition in the free space of a disk that holds data, swap on a
new logical volume, and removing swap cleanly.

## Before you start

The lab adds two 1 GiB spare disks. They're image files under
`/var/lib/le-lab/disks/`, attached again at every boot, before file
systems and swap are activated.

- `/dev/loop40` has a GPT table with one 300 MiB partition,
  `/dev/loop40p1`, holding an ext4 file system with data. The rest of the
  disk is free.
- `/dev/loop41` is a physical volume of the volume group `vglab`, with a
  logical volume `lvdata` and a 128 MiB swap logical volume `oldswap`,
  active and in `/etc/fstab`, as task 2 leaves a swap LV. Task 3 removes
  it, so task 2's result can stay.

## Tasks

1. On `/dev/loop40`, add a 512 MiB swap partition in the free space and
   make it active at every boot. The first partition and its data must
   stay unchanged.
2. Add a 256 MiB swap space on a new logical volume in `vglab`, active at
   every boot.
3. Remove the swap LV `oldswap` cleanly: not active, the LV gone, no
   fstab line naming it, and no `Timed out waiting for device` error at
   the next boot.

## Hints

- `fdisk` or `parted`: a new partition after the first; type Linux swap.
  `mkswap`, a line `UUID=... none swap defaults 0 0`, `swapon -a`,
  `swapon --show`.
- `lvcreate -L 256M -n`, `mkswap`, a line in `/etc/fstab`.
- `swapoff`, then remove its line from `/etc/fstab`,
  `systemctl daemon-reload`, then `lvremove`.
  `journalctl -b -p err` after a reboot.
