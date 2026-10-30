# RHCSA 4.4: Tuning profiles

Choosing the recommended tuning profile, setting one that lasts across
reboots, and what happens when the tuned daemon isn't running.

## Before you start

The lab installs tuned if it's missing, starts and enables it, and sets
the profile `balanced` (or `throughput-performance`, if `balanced` is the
one tuned recommends on your VM). Reset puts back the profile you had.

## Tasks

1. Set the VM's tuning profile to the one tuned recommends.
2. Set the profile to `powersave` and make sure it's still active after a
   reboot.
3. Stop and disable `tuned`, reboot, and see what `tuned-adm active` says;
   then put it right: tuned enabled and running again, with the profile
   you chose active.

## Hints

- `tuned-adm recommend`, `tuned-adm profile NAME`, `tuned-adm active`.
- `tuned-adm list`; the choice is kept in `/etc/tuned/active_profile`.
- `systemctl disable --now tuned`, then `systemctl enable --now tuned`.
