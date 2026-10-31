# Ubuntu Desktop 3.1: Boot problems: GRUB 2 and the initramfs

Making the GRUB menu show at every boot with kernel messages instead of
the logo, recovery mode, getting a system back from `grub rescue>`, and
rebuilding the initramfs. Tasks 2 and 3 need the VM's console.

## Before you start

The lab saves `/etc/default/grub` and `/etc/default/grub.d/` so reset can
put them back (and runs `update-grub` if they changed). It changes
nothing else. On cloud images,
`/etc/default/grub.d/50-cloudimg-settings.cfg` is read after
`/etc/default/grub` and sets `GRUB_TIMEOUT=0`.

## Tasks

1. Make the GRUB menu appear for 10 seconds at every boot, and make every
   boot show kernel messages instead of the logo (no `quiet` or `splash`
   on the kernel command line). Reboot to see it.
2. Boot once into recovery mode, get a root shell, and make sure `/` is
   writable. Not graded: in that shell, `cat /proc/cmdline` contains
   `recovery`, `systemctl is-active friendly-recovery.service` prints
   `active`, and `touch /root/recovery-test` succeeds.
3. Rename `/boot/grub` to `/boot/grub.bak`, reboot, and get the system
   booted from `grub rescue>`. Then repair it for good. Not graded: after
   `sudo mv /boot/grub.bak /boot/grub`, `sudo grub-install DISK` prints
   `Installation finished. No error reported.`, and the next reboot shows
   the normal menu. Take a snapshot of the VM before this one.
4. Rebuild the initramfs of every installed kernel.

## Hints

- `GRUB_TIMEOUT_STYLE=menu`, `GRUB_TIMEOUT=10` and
  `GRUB_CMDLINE_LINUX_DEFAULT`, in `/etc/default/grub` or a file in
  `/etc/default/grub.d/` that sorts after the cloud image's; then `sudo
  update-grub`. After a reboot, `cat /proc/cmdline`.
- In the menu: Advanced options, then the `(recovery mode)` entry, then
  `root`. `mount -o remount,rw /` if `/` is read-only.
- At `grub rescue>`: `set` shows the prefix GRUB looked in; `ls
  (hd0,gpt16)/` finds `grub.bak` (on cloud images `/boot` is its own
  partition). Then `set prefix=(hd0,gpt16)/grub.bak`, `set
  root=(hd0,gpt16)`, `insmod normal`, `normal`. `lsblk` shows the disk
  for `grub-install`.
- `sudo update-initramfs -u -k all` prints a `Generating` line for each
  kernel in `ls /boot/vmlinuz-*`.
