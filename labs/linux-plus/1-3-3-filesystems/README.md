# Linux+ 1.3.3: Filesystems

An ext4 and an XFS filesystem, running out of inodes with space to spare, a
filesystem check, and a quick benchmark.

## Before you start

The lab adds two empty 1 GiB spare disks, `/dev/loop40` and `/dev/loop41`
(the chapter's `vdb` and `vdc`). They come back at every boot.

## Tasks

1. Make an ext4 filesystem with only about 2000 inodes on `/dev/loop40`,
   and an XFS filesystem on `/dev/loop41`. Mount them at `/mnt/e` and
   `/mnt/x`, and compare their space and inodes.
2. Fill `/mnt/e` with empty files until it runs out of inodes while it
   still has space. Write the number of files you managed to create to
   `/root/lab-answers/2`, then delete them.
3. Unmount `/mnt/e` and check its filesystem with a forced fsck. Install
   fio and benchmark `/mnt/x` (random reads and writes of 4 KiB blocks on a
   200 MiB file, for 15 seconds), then remove the test file and unmount
   `/mnt/x`.

## Hints

- `mkfs.ext4 -N`, `mkfs.xfs`; `df -hT` and `df -i`.
- `for i in $(seq 1 3000); do touch /mnt/e/f$i || break; done`; `ls /mnt/e | wc -l`.
- `fsck -f`; `dumpe2fs -h` shows when a filesystem was last checked.
- `fio --name=t --filename=/mnt/x/t --size=200M --rw=randrw --bs=4k --direct=1 --runtime=15 --time_based`
