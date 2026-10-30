# RHCSA 10.7: SELinux booleans

A boolean turned on for good, and one turned on only until the next boot.

## Before you start

SELinux must be enforcing. The lab installs `policycoreutils-python-utils`
(for `semanage`) and turns `httpd_can_network_connect` and
`httpd_enable_homedirs` off, persistently. Task 2 ends where it started, so
the lab runs a small service, `le-lab-watch`, that notes
`httpd_enable_homedirs` every second (and at every boot) for the check.
Reset turns both booleans off again.

## Tasks

1. Let web servers make outgoing network connections, persistently: after
   a reboot, `getsebool httpd_can_network_connect` prints `--> on`.
2. Turn `httpd_enable_homedirs` on without `-P`: `semanage boolean -l`
   shows it `(on , off)`. Reboot: `getsebool httpd_enable_homedirs` prints
   `--> off`.

## Hints

- `getsebool -a | grep httpd`, `semanage boolean -l | grep httpd`;
  `setsebool -P`.
- `setsebool` without `-P` changes only the running system.
