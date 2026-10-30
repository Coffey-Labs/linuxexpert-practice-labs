# LFCS 3.2: The virtual file system

Mount options, remounting in place, bind mounts, tmpfs, and a safer `/tmp`.

## Before you start

The lab adds a 512 MiB spare disk, `/dev/loop40`, that already holds an ext4
filesystem. It comes back at every boot, before filesystems are mounted, so
an `/etc/fstab` line for it keeps working. It also creates user `alice`
(password `Lab-Pass-1`) and a directory `/srv/shared` with a file in it.

## Tasks

1. Mount the filesystem on `/dev/loop40` at `/data`, read-only and with
   `noexec`. Then make it read-write without unmounting it. Make `/data`
   mount read-write with `noexec` at every boot too.
2. Make `/srv/shared` also appear as `/home/alice/shared` at every boot.
3. Create a 256 MiB tmpfs at `/scratch`, writable by everyone with the
   sticky bit, present after every boot.
4. Make `/tmp` refuse to run programs and honor no set-user-ID bits, at
   every boot. If `/tmp` isn't a separate mount (`findmnt /tmp` shows
   nothing), add a line such as
   `tmpfs /tmp tmpfs defaults,noexec,nosuid,nodev,mode=1777 0 0`.

Check your `/etc/fstab` before you reboot: a bad line can stop the boot.

## Hints

- `mount -o ro,noexec`, `mount -o remount,rw`, `findmnt -no OPTIONS /data`.
  `blkid` gives the UUID for `/etc/fstab`.
- `mount --bind`; in `/etc/fstab` the type is `none` and the option `bind`.
- `mount -t tmpfs -o size=...,mode=...`; `df -h /scratch`, `ls -ld /scratch`.
- `findmnt --verify`, `systemctl daemon-reload`, `mount -a`.
