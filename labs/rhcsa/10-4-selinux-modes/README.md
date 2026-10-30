# RHCSA 10.4: SELinux modes

Switching to permissive mode for now, and booting in permissive mode and
back.

## Before you start

SELinux must be enforcing when you start. The tasks end where they
started, so the lab runs a small service, `le-lab-watch`, that notes the
SELinux mode and the `SELINUX=` setting every second (and at every boot)
for the check. Wait a few seconds between steps. Reset sets SELinux back
to enforcing.

## Tasks

1. Put SELinux into permissive mode until the next reboot, and make sure
   enforcing mode is the setting at boot: `getenforce` prints
   `Permissive` and `sestatus` shows `Mode from config file: enforcing`.
   After a reboot, `getenforce` prints `Enforcing`.
2. Make the system boot in permissive mode and reboot: `getenforce` prints
   `Permissive`. Then put it back to enforcing for good (`SELINUX=enforcing`
   and a reboot, or `setenforce 1` as well).

## Hints

- `setenforce 0`, `getenforce`, `sestatus`.
- `SELINUX=` in `/etc/selinux/config`; `setenforce 1`.
