# LFCS 4.2: Creating and configuring services

Writing a service unit, giving it an environment file, overriding a
packaged unit with a drop-in, and fixing a broken unit from its logs.

## Before you start

The lab installs `ticker.service`, which runs `/usr/local/bin/ticker` as
system user `ticker`. Someone broke its unit file: it fails to start. For
the program in task 1, a script that loops forever writing the date to its
output works.

## Tasks

1. Write a service `heartbeat` that runs a script as a new system user
   `heartbeat`, restarts on failure after 5 seconds, and starts at boot.
2. Make the service read a variable `INTERVAL` from
   `/etc/default/heartbeat` and use it (for example, as the number of
   seconds between lines).
3. Make the packaged chrony service restart always, in a way that survives
   package updates. Install chrony if it's missing; the unit is `chronyd`
   on RHEL and `chrony` on Debian and Ubuntu.
4. `ticker.service` has a wrong `ExecStart` path and a user that doesn't
   exist. Find and fix both from the logs, so that it runs and starts at
   boot.

## Hints

- `useradd -r`, a unit in `/etc/systemd/system/`, `Restart=`,
  `RestartSec=`, `systemctl daemon-reload`, `systemctl enable --now`.
  `sudo systemctl kill -s KILL heartbeat` tests the restart.
- `EnvironmentFile=`, `systemctl show heartbeat -p EnvironmentFiles`.
- `systemctl edit`, `systemctl cat`, `systemctl show -p Restart`.
- `systemctl status ticker`, `journalctl -u ticker`,
  `systemd-analyze verify ticker.service`.
