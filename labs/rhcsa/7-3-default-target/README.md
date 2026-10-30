# RHCSA 7.3: The default boot target

Switching the default boot target, and booting into `multi-user.target`.

## Before you start

Task 1 ends where it started, so the lab runs a small service,
`le-lab-watch`, that notes the default target every second (and at every
boot) for the check. The lab puts the default target back as it was when
you reset it.

## Tasks

1. Make the system boot into `graphical.target` by default, then back into
   `multi-user.target`. Look at `systemctl get-default` and at the
   `/etc/systemd/system/default.target` link after each change.
2. Set the default to `multi-user.target` and reboot. After the reboot,
   `graphical.target` isn't active.

## Hints

- `systemctl set-default`, `systemctl get-default`;
  `ls -l /etc/systemd/system/default.target`.
- `systemctl list-units --type=target --state=active`.
