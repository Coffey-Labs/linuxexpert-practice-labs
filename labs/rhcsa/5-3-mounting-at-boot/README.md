# RHCSA 5.3: Mounting by UUID or label

Mounting file systems at boot by UUID and by label, and finding a bad
`/etc/fstab` line without rebooting.

## Before you start

The lab adds two empty 1 GiB spare disks, `/dev/loop40` and
`/dev/loop41`. They're image files under `/var/lib/le-lab/disks/`,
attached again at every boot, before file systems are mounted. Use them
whole or partition them.

It also adds a line to `/etc/fstab` for a UUID that doesn't exist, at
`/mnt/archive`. That line has `nofail`, so it doesn't stop the boot.

## Tasks

1. Make an XFS file system on a spare disk (or a partition or LV on it)
   and mount it on `/data` at every boot, by UUID.
2. Make an ext4 file system labeled `backups` and mount it on `/backups`
   at every boot, by label.
3. Find the bad `/mnt/archive` line without rebooting, then remove it.
   `findmnt --verify` should then report no errors and no warnings.

## Hints

- `mkfs.xfs`, `blkid`, a line `UUID=... /data xfs defaults 0 0`, then
  `systemctl daemon-reload` and `mount -a`.
- `mkfs.ext4 -L backups`, or `e2label`; `LABEL=backups /backups ext4
  defaults 0 2`.
- `findmnt --verify` marks the bad line with `[E]`; run
  `systemctl daemon-reload` after editing `/etc/fstab`. Run `findmnt
  --verify` as root: as a normal user it can't read the devices and warns
  `cannot detect on-disk filesystem type (Permission denied)` for every
  line.
