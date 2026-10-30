# RHCSA 7.2: Services at boot

Starting a service now and at every boot, masking it so nobody can start
it, and undoing that.

## Before you start

The tasks change the same service one after another, so the lab runs a
small service, `le-lab-watch`, that notes httpd's state every second
(and at every boot) for the check. Do the tasks in order.

## Tasks

1. Install `httpd`, and make it start now and at every boot. Reboot, and
   see that it's enabled and running.
2. Stop `httpd` and make sure nobody can start it by hand.
3. Undo that, leaving `httpd` stopped and disabled.

## Hints

- `dnf install`, `systemctl enable --now`; `systemctl is-enabled`,
  `systemctl is-active`.
- `systemctl stop`, `systemctl mask`; `systemctl start httpd` then fails
  with "Unit httpd.service is masked."
- `systemctl unmask`; check `is-enabled` and `is-active` again.
