# Linux+ 1.3.5: Software RAID

A RAID 1 mirror with a hot spare, a failed disk, the spare taking over, and
the old disk coming back as the new spare.

## Before you start

The lab installs `mdadm` and adds three empty 1 GiB spare disks,
`/dev/loop40`, `/dev/loop41` and `/dev/loop42` (the chapter's `vdb`, `vdc`
and `vdd`). They come back at every boot, but the array isn't set up to
start and mount at boot, so do the tasks in one go and run `le-lab check`
before you clean up.

## Tasks

1. Build `/dev/md0`, a RAID 1 of `/dev/loop40` and `/dev/loop41` with
   `/dev/loop42` as a spare. Put ext4 on it, mount it at `/mnt/raid`, and
   write `hello` to `/mnt/raid/file`.
2. Mark `/dev/loop40` as failed and watch the spare take over. The file is
   still readable.
3. Remove the failed disk from the array, wipe its RAID superblock, and add
   it back as the new spare.

When `le-lab check` passes, clean up as the chapter shows (unmount, stop the
array, wipe the superblocks), or leave it to `le-lab reset`.

## Hints

- `mdadm --create /dev/md0 --level=1 --raid-devices=2 --spare-devices=1 --metadata=1.2 ...`;
  `cat /proc/mdstat`; `mdadm --wait /dev/md0` waits for a sync to finish.
- `mdadm /dev/md0 --fail DISK`; `mdadm --detail /dev/md0`.
- `mdadm /dev/md0 --remove DISK`, `mdadm --zero-superblock DISK`,
  `mdadm /dev/md0 --add DISK`.
