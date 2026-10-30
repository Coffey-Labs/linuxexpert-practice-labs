# LPIC-1 104.2: Keeping filesystems healthy

Running out of inodes, checking ext4 with `e2fsck`, backup superblocks,
`tune2fs`, checking XFS, and space held by deleted files.

## Before you start

The lab adds two empty spare disks: `/dev/loop40` (100 MiB) and
`/dev/loop41` (512 MiB). Write answers to the files in
`/root/lab-answers/`.

## Tasks

1. Make a 100 MiB ext4 filesystem with few inodes and 1 KiB blocks on
   `/dev/loop40` (`mkfs.ext4 -N 1000 -b 1024`), mount it, and create empty
   files in a loop until it fails. Compare `df -h` and `df -i`. (With the
   4 KiB blocks Ubuntu picks, a filesystem this small has a single block
   group and no backup superblock for task 3.)
2. Unmount it and run `e2fsck`, then `e2fsck -f`, and read the five
   passes.
3. Find the backup superblocks with `dumpe2fs`, then run `e2fsck -f -b
   BACKUP /dev/loop40` with the first one. Expect it to report something
   "FIXED" and "FILE SYSTEM WAS MODIFIED" even on a healthy filesystem: it
   rewrites the main superblock from the backup. Write the block number of
   the first backup superblock to `/root/lab-answers/3`.
4. Change the filesystem's label to `scratch` and its reserved percentage
   to 2 with `tune2fs`, and check both with `tune2fs -l`.
5. Make an XFS filesystem on `/dev/loop41`, run `xfs_repair -n` on it
   unmounted, then mount it and run `xfs_info`.
6. Delete a large file while `tail -f` holds it open, and compare `df` and
   `du` before and after stopping `tail`. Check it yourself: `df` gets the
   space back only when `tail` ends.

## Hints

- `for i in $(seq 2000); do touch /mnt/small/f$i || break; done`;
  `df -i`.
- `umount`; plain `e2fsck` skips a clean filesystem, `-f` forces it.
- `dumpe2fs /dev/loop40 | grep -i superblock`.
- `tune2fs -L`, `tune2fs -m`, `tune2fs -l | grep -Ei 'volume name|reserved block|block count'`.
- `mkfs.xfs`, `xfs_repair -n`, `xfs_info MOUNTPOINT`.
- `lsof +L1` lists deleted files that are still open.
