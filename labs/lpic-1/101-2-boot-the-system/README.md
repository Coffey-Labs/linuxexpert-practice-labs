# LPIC-1 101.2: Booting the system

Booting into a different target from the GRUB menu, keeping the journal
across reboots, and finding out which init the system runs.

## Before you start

The lab makes the journal volatile: if `/var/log/journal` exists, it moves
it aside (reset puts it back), so the journal is kept only in memory under
`/run/log/journal` and is lost at every reboot. It also notes the current
boot. Write answers to the files in `/root/lab-answers/`.

## Tasks

1. Boot once with `systemd.unit=rescue.target` added at the GRUB menu, log
   in, and check `/proc/cmdline`. Check it yourself: `/proc/cmdline`
   showed the option during that boot, and the next normal boot didn't
   have it.
2. Make the journal persistent by creating `/var/log/journal`, reboot
   twice, then list the boots with `journalctl --list-boots` and read the
   previous one with `journalctl -b -1`.
3. Find out which init the VM runs with `ps -p 1 -o comm=`, then look at
   `ls -l /sbin/init`. Write the name of PID 1 on line 1 of
   `/root/lab-answers/3`, and the file `/sbin/init` points to on line 2.

## Hints

- At the GRUB menu, `e` edits the entry for one boot; add the option to
  the end of the `linux` line and press Ctrl+X. If the menu doesn't show,
  hold Shift or press Esc while the VM starts.
- `mkdir /var/log/journal`, then `systemd-tmpfiles --create --prefix
  /var/log/journal` and `journalctl --flush` (or restart
  systemd-journald) to start using it without a reboot.
- `journalctl --list-boots`, `journalctl -b -1 -n 20`.
- `ps -p 1 -o comm=`, `ls -l /sbin/init`, `readlink -f /sbin/init`.
