# Ubuntu Server 3.2: Regular and system users

Telling login accounts from system accounts, a system user for a service,
and a service that runs as it.

## Before you start

The lab adds a few accounts so the lists in task 1 have something to tell
apart: `maria` (a regular user with a shell), `kiosk` (a regular UID with
no login shell) and `buildbot` (a system UID with a shell). Write answers
to the files in `/root/lab-answers/`, one account name per line.

## Tasks

1. List every account that can log in with a shell, into
   `/root/lab-answers/1-shells`, and every account with a UID of 1000 or
   more, into `/root/lab-answers/1-uids`.
2. Create a system user `reportsvc` with its own group, a data directory
   `/var/lib/reportsvc` that only it can write to, and no login.
   `sudo -u reportsvc touch /var/lib/reportsvc/ok` works and
   `sudo -u reportsvc touch /etc/ok` fails.
3. Run a `python3 -m http.server 8080` service as `reportsvc` with a
   systemd unit, started at boot. `curl -s localhost:8080 | head -1`
   prints HTML.

## Hints

- `/etc/passwd`: the UID is field 3 and the shell field 7.
  `grep -v -E 'nologin|false|sync$' /etc/passwd`, `awk -F: '$3>=1000'`,
  `cut -d: -f1`.
- `useradd --system --user-group --shell /usr/sbin/nologin`, `id`,
  `getent passwd`; `install -d -o -g -m 755`.
- `User=`, `WorkingDirectory=` in a unit in `/etc/systemd/system/`;
  `systemctl enable --now`; `ps -o user= -C python3`.
