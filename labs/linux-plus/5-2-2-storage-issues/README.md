# Linux+ 5.2.2: Storage problems

An fstab entry that mounts nothing, a filesystem that's out of inodes, and
a deleted file that still takes up space.

## Before you start

The lab adds three spare disks, image files under
`/var/lib/le-lab/disks/` that are attached again at every boot, each with
an ext4 filesystem and a line in `/etc/fstab`:

- `/dev/loop40`, meant to be mounted on `/mnt/lab`;
- `/dev/loop41`, mounted on `/mnt/inodes`, where an application keeps a
  cache (`/mnt/inodes/cache/`, safe to delete) and its data
  (`/mnt/inodes/data/`, keep it);
- `/dev/loop42`, mounted on `/mnt/scratch`, used by the service
  `report-cache`.

Write answers to the files in `/root/lab-answers/`.

## Tasks

1. `/mnt/lab` isn't mounted, though `/etc/fstab` has a line for it. Find
   the error, and fix the line so that `mount -a` mounts `/dev/loop40`
   there, now and at boot.
2. The application can't create files in `/mnt/inodes/data`, yet `df -h`
   shows free space. Find out why, write the resource that ran out to
   `/root/lab-answers/2`, and make room without touching `data/`.
3. `/mnt/scratch` is nearly full, but `du` finds almost nothing there. Find
   the process that holds the space, write its name to
   `/root/lab-answers/3`, and free the space.

## Hints

- `findmnt --verify`, `blkid`, `lsblk -f`; `systemctl daemon-reload`
  after editing fstab.
- `df -h` versus `df -i`.
- `lsof +L1` (install `lsof` if it's missing), or `ls -l /proc/*/fd`
  looking for `(deleted)`; `ps`, `systemctl status`.
