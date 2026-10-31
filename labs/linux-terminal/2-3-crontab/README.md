# Using Linux Terminal 2.3: Crontab format and location

A user crontab with a repeating job and a boot job, a system job in
`/etc/cron.d`, and keeping one user away from crontab.

## Before you start

The lab creates users `student` and `alice` (password `Lab-Pass-1`), puts
a harmless script at `/usr/local/bin/cleanup`, and makes sure cron is
running. It saves `/etc/cron.allow` and `/etc/cron.deny` (if they exist)
and puts them back on reset. Task 1 needs a few minutes of waiting and a
reboot.

## Tasks

1. As `student` (`sudo -iu student`), add a cron job that appends the date
   to `~/ticks.log` every two minutes, and one that writes `booted` to
   `~/boot.log` at every boot. Wait until `~/ticks.log` has a date or two,
   then reboot and look at `~/boot.log`.
2. Make a system job that runs `/usr/local/bin/cleanup` as root at 3:15 am
   on the first day of every month, in its own file under `/etc/cron.d`.
3. Stop `alice` from using crontab, without touching anyone else: her
   `crontab -l` says she isn't allowed, and `student`'s still works.

## Hints

- `crontab -e`, `crontab -l`; `*/2 * * * *` and `@reboot`; `>>` appends,
  `>` overwrites.
- Files in `/etc/cron.d` have a user field after the five time fields, and
  cron skips files whose names contain a dot.
- `/etc/cron.deny` lists users who may not use crontab; a `cron.allow`
  would shut out everyone it doesn't list.
