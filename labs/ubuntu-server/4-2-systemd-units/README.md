# Ubuntu Server 4.2: Listing systemd units

Counting and listing units by state, finding failed services, and masking.

## Before you start

Like a server you don't know, this VM has a problem waiting: the lab adds
a service that fails at every boot. It doesn't tell you its name. Write
answers to the files in `/root/lab-answers/`.

## Tasks

1. Count the services that are running, and write the number to
   `/root/lab-answers/1`. List the services that are installed but
   disabled, one per line, in `/root/lab-answers/1-disabled`.
2. Write a service whose `ExecStart=` points at a program that doesn't
   exist, start it, and find it the way you would on a server you don't
   know. You'll find the lab's failed service too: write its name and the
   status code `systemctl status` shows for it (such as `1/FAILURE`) to
   `/root/lab-answers/2`. Then delete both units, run `daemon-reload` and
   `reset-failed`, so that `systemctl --failed` lists `0 loaded units`.
3. Mask `apport`, then list every masked unit into
   `/root/lab-answers/3`. Unmask it afterwards, so `systemctl is-enabled
   apport` prints `enabled` again.

## Hints

- `systemctl list-units --type=service --state=running --no-legend`,
  `wc -l`; `systemctl list-unit-files --type=service --state=disabled`.
- `systemctl --failed`, `systemctl status NAME`, `systemctl cat NAME`,
  `journalctl -u NAME`; `systemctl reset-failed`.
- `systemctl mask`, `systemctl list-unit-files --state=masked`,
  `systemctl unmask`.
