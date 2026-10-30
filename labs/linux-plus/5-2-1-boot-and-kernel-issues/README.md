# Linux+ 5.2.1: Boot, kernel and driver problems

A service that won't start, a driver that won't load, the GRUB menu, and
the kernels to fall back to.

## Before you start

The lab installs nginx and enables it, but its configuration is broken, so
it doesn't start. Something on this VM also stops the `dummy` network
driver from loading. Write answers to the files in `/root/lab-answers/`.
Task 3 needs the VM's console, and a root password for rescue mode.

## Tasks

1. nginx failed to start. Find out why from its status, the journal and
   nginx's own test, and write the file and line number of the error (as
   `FILE:LINE`) to `/root/lab-answers/1`. Fix it so nginx runs.
2. `modprobe dummy` fails. Find what blocks it, write the path of that
   file to `/root/lab-answers/2`, and fix it so the driver loads.
3. Practice the GRUB menu: boot once into `rescue.target` by editing the
   kernel line, look around with `systemctl list-units --type=target`,
   then `systemctl default`. Rescue mode needs a root password: if root is
   locked, set one first, and lock it again afterward. Not graded.
4. List the kernels you could fall back to, and write their versions, one
   per line, to `/root/lab-answers/4`.

## Hints

- `systemctl --failed`, `systemctl status`, `journalctl -u nginx -n 5`,
  `nginx -t`.
- `modprobe -v`, `grep -r dummy /etc/modprobe.d/`, `modprobe -c`.
- `e` at the GRUB menu (on Ubuntu, Esc or Shift to show it),
  `systemd.unit=rescue.target`, Ctrl+X.
- `grubby --info=ALL | grep ^kernel` (RHEL family) or `ls /boot/vmlinuz-*`.
