# RHCSA 7.1: Scheduling tasks: at, cron and systemd timers

A crontab for another user, a systemd timer that runs every 15 minutes,
and one-off jobs with `at`.

## Before you start

The lab creates user `alice` (password `Lab-Pass-1`) with an empty
crontab, makes sure cron is running, and removes `/tmp/at-ran`. `at` isn't
set up; installing it and starting its service is part of task 3.

## Tasks

1. As root, schedule a job for user `alice` that runs `/usr/bin/logger
   hello` every weekday at 14:30.
2. Make a systemd timer that runs a script every 15 minutes and survives a
   reboot. After a reboot, `systemctl list-timers` lists it with a next run
   at most 15 minutes away; wait until it has fired once.
3. Use `at` to create a file `/tmp/at-ran` two minutes from now. Then
   schedule another job and cancel it.

## Hints

- `crontab -u alice -e`, `crontab -l -u alice`; fields are minute, hour,
  day of month, month, day of week.
- A script (`chmod +x`), a `.service` with `Type=oneshot` and `ExecStart=`,
  and a `.timer` with `OnCalendar=*:0/15` (or `OnUnitActiveSec=15min`
  with `OnBootSec=`) in `/etc/systemd/system/`; `systemctl daemon-reload`,
  `systemctl enable --now NAME.timer`; `journalctl -u NAME.service`.
- `dnf install at`, `systemctl enable --now atd`; `at now + 2 minutes`,
  `atq`, `atrm`.
