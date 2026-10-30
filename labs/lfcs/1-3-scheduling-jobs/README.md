# LFCS 1.3: Scheduling jobs

A crontab for another user, a one-off job with at, a systemd timer, and
who may use cron.

## Before you start

The lab creates users `alice` and `bob` (password `Lab-Pass-1`) and makes
sure cron is installed and running. `at` isn't set up; installing it and
starting its service is part of task 2.

## Tasks

1. As root, schedule `/usr/bin/date >> /tmp/alice-date.log` to run for user
   `alice` at 02:30 every weekday.
2. Schedule a job for 10 minutes from now that writes `hello` to
   `/tmp/at-test`. Check it's queued, write its job number to
   `/root/lab-answers/2`, then cancel it.
3. Create `cleanup.service` and `cleanup.timer` that delete files in
   `/tmp/scratch` older than 7 days (`find /tmp/scratch -mtime +7 -delete`)
   every day at 03:00, catching up after downtime. The timer must be enabled
   and running.
4. Stop user `bob` using crontab while everyone else still can.

## Hints

- `crontab -u alice -e`, `crontab -u alice -l`.
- The `at` package and its `atd` service; `at now + 10 minutes`, `atq`,
  `atrm`.
- `OnCalendar=`, `Persistent=`, `systemctl enable --now`,
  `systemctl list-timers`, `systemd-analyze calendar`.
- `/etc/cron.allow` and `/etc/cron.deny`.
