# Ubuntu Desktop 4.1: Listing and upgrading packages

Counting what's installed, upgrading everything but one held package,
reading apt's history, and holding a snap's updates.

## Before you start

The lab changes nothing; reset takes away the holds you add. The VM needs
to reach the Ubuntu archive (and the snap store for task 4). Write
answers to the files in `/root/lab-answers/`.

## Tasks

1. Count the installed deb packages, and list the snaps. Write the count
   to `/root/lab-answers/1`.
2. Bring every deb package up to date, holding back one package that has
   an update (or any installed package, if none has).
3. Find out when the last apt command that upgraded packages was run, and
   by whom. Write its `Start-Date` (date and time) on line 1 of
   `/root/lab-answers/3`, and on line 2 the user, `root`, or
   `unattended-upgrade` for the automatic daily run.
4. Stop a snap from updating for two days, then undo it. If `snap list`
   shows no snaps (as on a server), install the small `hello` snap first.
   Not graded: check that `snap list NAME` shows `held` in Notes, and
   that after `--unhold` it doesn't.

## Hints

- `dpkg -l | grep -c '^ii'`; `snap list`.
- `apt update`, `apt list --upgradable`, `apt-mark hold`, `apt upgrade`.
  `apt-mark showhold` shows the hold, and its `dpkg -l` line starts with
  `hi`. Updates that `apt upgrade` reports as deferred due to phasing may
  stay.
- `/var/log/apt/history.log`: the last entry with an `Upgrade:` line, its
  `Start-Date`, `Commandline` and `Requested-By` (only there when the
  command ran through sudo).
- `snap refresh --hold=48h NAME`, `snap refresh --unhold NAME`.
