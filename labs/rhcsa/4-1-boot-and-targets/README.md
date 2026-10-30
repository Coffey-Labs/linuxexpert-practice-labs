# RHCSA 4.1: Booting, shutting down and targets

Booting into the rescue target, recovering from a bad `/etc/fstab` line in
the emergency shell, scheduling and cancelling a reboot, and switching
targets on a running system.

## Before you start

Take a snapshot first: this lab breaks the boot on purpose. The lab adds a
line to `/etc/fstab` for a disk that doesn't exist (label `le-nodisk`, at
`/mnt/nodisk`, without `nofail`), so **the next boot stops in emergency
mode**. Emergency and rescue mode ask for the root password and refuse if
root is locked, as it is on most cloud images: give root a password first
with `sudo passwd root`.

## Tasks

1. From the GRUB menu, boot into `rescue.target` once. Check it yourself:
   after logging in with the root password,
   `systemctl list-units --type=target --state=active` shows
   `rescue.target` and not `multi-user.target`.
2. Reboot, and fix the boot from the emergency shell, so that the system
   reaches `multi-user.target` again and `systemctl --failed` lists no
   mount units.
3. Schedule a reboot for 15 minutes from now with a message, look at
   `/run/systemd/shutdown/scheduled`, then cancel it.
4. On a VM with a desktop, switch the running system to the text-only
   target and back without rebooting. Check it yourself:
   `systemctl is-active graphical.target` is `inactive` after the first
   switch and `active` after the second.

## Hints

- At the GRUB menu, `e` edits the entry for one boot: add
  `systemd.unit=rescue.target` to the `linux` line, then Ctrl+X.
- In emergency mode: `mount -o remount,rw /` if needed, edit
  `/etc/fstab`, `systemctl daemon-reload`, `mount -a`, then Ctrl+D or
  `reboot`. `findmnt --verify`.
- `shutdown -r +15 "message"`, `shutdown -c`.
- `systemctl isolate multi-user.target`, then `graphical.target`.
