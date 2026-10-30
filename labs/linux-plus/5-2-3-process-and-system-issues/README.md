# Linux+ 5.2.3: Process, package and access problems

A segfault and its core dump, the OOM killer in a memory-limited scope, a
stopped process, and the cron PATH problem.

## Before you start

The lab makes the journal persistent if it isn't. It starts a service,
`queue-worker`, that adds one to the number in `/var/lib/queue-worker/count`
every second, and creates user `ops`, whose crontab runs a tool from
`/usr/local/sbin` every minute, logging to `/home/ops/labtool.log`.
Something is wrong with both. The stopped process doesn't survive a
reboot: do the tasks and check without rebooting. Write answers to the
files in `/root/lab-answers/`.

## Tasks

1. Make a process die of a segmentation fault (`bash -c 'kill -SEGV
   $$'`), note its exit code, and find its core dump with `coredumpctl`
   (on Ubuntu, install `systemd-coredump` first).
2. Watch the OOM killer act inside a scope limited to 50 MiB of memory
   with no swap, and find its message in the kernel log.
3. `queue-worker` is running, but the count doesn't go up. Find out why,
   write the state code `ps` shows for its process to
   `/root/lab-answers/3`, and get it going again without restarting it.
4. User `ops`'s cron job fails every minute. Find out why from its log,
   and fix the crontab entry so that it runs (as user `ops`). Wait for
   the next run and see `labtool ran` at the end of the log.

## Hints

- `echo $?` (128 + the signal number), `coredumpctl list`,
  `coredumpctl info`.
- `systemd-run --scope -p MemoryMax=50M -p MemorySwapMax=0 python3 -c
  ...`, `journalctl -k --since "-2min" | grep -i -E 'oom|killed'`.
- `systemctl status`, `ps -o pid,stat,cmd -p PID`, `kill -CONT`.
- `crontab -l -u ops`, `crontab -e -u ops`; cron's `PATH` is short: use
  the full path, or set `PATH=` in the crontab.
