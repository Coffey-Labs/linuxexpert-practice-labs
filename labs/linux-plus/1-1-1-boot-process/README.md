# Linux+ 1.1.1: The boot process

How the system booted, a trip into rescue mode, and a lasting change to the
kernel command line.

## Before you start

Take a snapshot first: task 2 and task 3 go through the boot loader. On the
RHEL family the lab adds `quiet` to every kernel's command line if it isn't
there, so that task 3 has something to remove. On Ubuntu it makes sure
`loglevel=7` isn't set. Reset puts the boot loader settings back as they
were.

## Tasks

1. Find out how this system booted. Write `UEFI` or `BIOS` on the first
   line of `/root/lab-answers/1`, and the default systemd target (such as
   `multi-user.target`) on the second.
2. Boot once into rescue mode from the boot loader menu, log in as root,
   run `systemctl list-units --state=running`, then `systemctl reboot`. Not
   graded: check yourself that only a handful of units were running. Root
   needs a password for rescue mode (`passwd root`); lock it again
   afterward with `passwd -l root`.
3. Make a lasting change to the kernel command line, then reboot. RHEL
   family: remove `quiet` from every installed kernel with grubby. Ubuntu:
   add `loglevel=7` to `GRUB_CMDLINE_LINUX_DEFAULT` and run `update-grub`.
   Check `/proc/cmdline` after the reboot. Leave the change in place until
   you've run `le-lab check`; reset puts it back.

## Hints

- `/sys/firmware/efi` exists only on UEFI systems; `systemctl get-default`.
- In the GRUB menu, **e** edits an entry: add `systemd.unit=rescue.target`
  to the end of the `linux` line and press **Ctrl+x**. Press **Esc** or hold
  **Shift** if the menu is hidden.
- `grubby --update-kernel=ALL --remove-args=...`, `grubby --info=ALL`.
- On Ubuntu, files in `/etc/default/grub.d/` are read after
  `/etc/default/grub` and can set the same variable; cloud images set
  `GRUB_CMDLINE_LINUX_DEFAULT` in `50-cloudimg-settings.cfg`.
