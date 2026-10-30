# RHCSA 7.6: The boot loader

Adding and removing a kernel argument on every installed kernel, and the
GRUB menu timeout.

## Before you start

These tasks change the boot loader, so take a snapshot of the VM first.
Tasks 1 and 2 add an argument and take it away again, so the lab runs a
small service, `le-lab-boot-note`, that notes the kernel command line at
every boot for the check. The lab notes your GRUB timeout and puts it back
when you reset it. Do the tasks in order.

## Tasks

1. Add the kernel argument `audit_backlog_limit=8192` to every installed
   kernel, reboot, and confirm the running kernel got it.
2. Remove that argument again, from every kernel and from
   `/etc/default/grub`.
3. Change the GRUB menu timeout to 10 seconds.

## Hints

- `grubby --update-kernel=ALL --args=...`, `grubby --info=ALL | grep
  ^args`; `cat /proc/cmdline` after the reboot.
- `grubby --update-kernel=ALL --remove-args=...`; `grep CMDLINE
  /etc/default/grub`.
- `GRUB_TIMEOUT` in `/etc/default/grub`, then
  `grub2-mkconfig -o /boot/grub2/grub.cfg`; `grep -m1 'set timeout='
  /boot/grub2/grub.cfg`.
