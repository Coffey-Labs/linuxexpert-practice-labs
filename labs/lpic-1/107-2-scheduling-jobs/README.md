# LPIC-1 107.2: Scheduling jobs

A user crontab, one-off jobs with `at`, who may use cron, and the same job
as a systemd timer.

## Before you start

The lab creates user `alice` (password `Lab-Pass-1`) and makes sure cron is
installed and running. `at` isn't set up: installing it and starting `atd`
is part of task 2. Tasks 1 and 2 need a few minutes of waiting.

## Tasks

1. As `alice`, add a crontab entry that appends the output of `date` to
   `~/date.log` every two minutes. Wait until the file has a line or two,
   then remove the entry.
2. Queue a job with `at now + 2 minutes` that writes `first` to
   `/var/tmp/at-first`. List it with `atq`, read it with `at -c`, and let it
   run. Then queue another that would write `second` to `/var/tmp/at-second`,
   write its job number to `/root/lab-answers/2`, and remove it with
   `atrm`.
3. Put `alice` in `/etc/cron.deny` and try `crontab -e` as her. Then create
   `/etc/cron.allow` without her name, and try again.
4. Turn the two-minute job into `datelog.service` and `datelog.timer`: the
   service runs as `alice` and appends `date` to `/home/alice/date.log`, and
   the timer runs it with `OnCalendar=*:0/2`. Enable and start the timer,
   and watch `systemctl list-timers` and `journalctl -u datelog`.

## Hints

- `crontab -e`, `crontab -l`, `*/2 * * * *`; `crontab -r` or edit the line
  out.
- The `at` package and its `atd` service; `atq`, `at -c`, `atrm`.
- `/etc/cron.deny`, `/etc/cron.allow`; `crontab -l` as `alice` shows the
  refusal.
- `[Service]` with `Type=oneshot`, `User=alice`, and a shell for the `>>`:
  `ExecStart=/bin/sh -c '...'`. `[Timer]` and `[Install]
  WantedBy=timers.target`. `systemd-analyze calendar '*:0/2'`.
