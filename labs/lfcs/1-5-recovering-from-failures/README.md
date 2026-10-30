# LFCS 1.5: Recovering from failures

A bad `/etc/fstab` line, lost passwords, a damaged filesystem, and a disk
that mustn't stop the boot.

## Before you start

Take a snapshot first: this lab breaks the boot on purpose. The lab adds a
line to `/etc/fstab` that mounts a device that doesn't exist (label
`le-missing`, at `/mnt/missing`), so **the next boot stops in emergency
mode**. Emergency mode asks for the root password and refuses if root is
locked, as it is on most cloud images: give root a password first with
`sudo passwd root`.

It also adds two spare disks: `/dev/loop40` with one empty partition,
`/dev/loop40p1`, and `/dev/loop41` with an ext4 filesystem mounted at
`/mnt/data` from `/etc/fstab`. They're image files under
`/var/lib/le-lab/disks/`, attached again at every boot.

## Tasks

1. Reboot, and recover from emergency mode so the system boots normally
   again. `findmnt --verify` should report no errors.
2. On the RHEL-family VM, reset the root password: `rd.break` on RHEL 9,
   `init=/bin/bash` on RHEL 10. Check it yourself: you can log in as root
   with the new password after the relabel.
3. On the Ubuntu VM, reset your admin user's password with
   `init=/bin/bash`. Check it yourself: you can log in with the new
   password and `sudo -v` works.
4. Create an ext4 filesystem on `/dev/loop40p1`, write some files, unmount
   it, damage it with
   `sudo dd if=/dev/zero of=/dev/loop40p1 bs=4096 seek=10 count=50` (this
   hits the resize inode; e2fsck will offer to recreate it), and repair it.
   Leave it unmounted.
5. Change the `/etc/fstab` entry of `/mnt/data` so that a missing disk no
   longer stops the boot. To test it, move
   `/var/lib/le-lab/disks/disk1.img` somewhere else and reboot: the system
   should still reach the normal target. Move it back and reboot again
   before you check.

## Hints

- In emergency mode: `mount -o remount,rw /`, edit `/etc/fstab`,
  `systemctl daemon-reload`, `mount -a`.
- At the GRUB menu, `e` edits the entry for one boot; Ctrl+X boots it.
  `touch /.autorelabel` on RHEL relatives.
- `mkfs.ext4`, `e2fsck -fy`, `e2fsck -fn`, `tune2fs -l`.
- The `nofail` mount option.
