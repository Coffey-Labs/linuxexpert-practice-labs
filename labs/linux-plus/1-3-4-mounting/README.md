# Linux+ 1.3.4: Mounting filesystems

An `/etc/fstab` line by UUID with mount options, `noexec` in action, a
remount, and finding what keeps a mount busy.

## Before you start

The lab adds a 512 MiB spare disk, `/dev/loop40`, with an ext4 filesystem on
it. It comes back at every boot. Task 2 changes the mount only until it's
mounted again, so do the tasks in one go and run `le-lab check` before you
clean up.

## Tasks

1. Add `/dev/loop40` to `/etc/fstab` by its UUID, mounted at `/mnt/lab` with
   the options `defaults,noatime,noexec,nofail`, and mount it from fstab.
2. Copy `/usr/bin/true` into `/mnt/lab` and show that it won't run from
   there. Then remount `/mnt/lab` so that programs can run from it, without
   changing `/etc/fstab`.
3. Make the mount busy (`cd /mnt/lab`), try to unmount it, and find the
   culprit with `lsof`. Not graded.

When `le-lab check` passes, remove your line from `/etc/fstab`, run
`systemctl daemon-reload` and unmount, or leave it to `le-lab reset`.

## Hints

- `blkid /dev/loop40`, `blkid -s UUID -o value`.
- After editing fstab: `systemctl daemon-reload`, `mount -a`, `findmnt /mnt/lab`.
- `mount -o remount,exec`.
- `lsof +D /mnt/lab`, `fuser -vm /mnt/lab`. Minimal RHEL-family installs need
  the `lsof` package.
