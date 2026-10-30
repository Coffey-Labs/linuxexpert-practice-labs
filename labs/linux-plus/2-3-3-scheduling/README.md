# Linux+ 2.3.3: Scheduling jobs

A cron job that runs every minute, the environment cron jobs get, and a
one-off job with `at`.

## Before you start

Work as root. The lab makes sure cron is installed and running, and
removes old copies of the files the tasks create in `/tmp`. Two of the
tasks take a few minutes of waiting.

## Tasks

1. Add a job to your crontab that appends the output of `date` to
   `/tmp/cron-test.txt` every minute. When it has run at least twice,
   remove the job from your crontab again (keep the file).
2. Add a job to your crontab that writes its environment (`env`) to
   `/tmp/cron-env.txt` every minute. When it has run, compare that file
   with your shell's environment, then remove the job (keep the file).
3. Install `at` if needed and make sure `atd` is running and starts at
   boot. Schedule a one-off job that creates `/tmp/at-ran` two minutes
   from now, and wait for it.

## Hints

- `(crontab -l 2>/dev/null; echo '* * * * * ...') | crontab -`,
  `crontab -l | grep -v PATTERN | crontab -`.
- `diff <(sort /tmp/cron-env.txt) <(env | sort)`: cron's `PATH` and
  `SHELL` are minimal.
- `systemctl enable --now atd`, `echo 'touch /tmp/at-ran' | at now + 2
  minutes`, `atq`.
- The chapter's step 4 (anacron and `/etc/crontab`) isn't graded.
