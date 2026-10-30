# Linux+ 5.5.1: CPU and memory performance

A baseline with sar, a CPU bottleneck, a process that switches context all
the time, and a slow boot.

## Before you start

The lab installs sysstat with collection off, starts two services that
load this VM in different ways, and adds a unit that slows the boot.
**Reboot once** after setup, so that the last boot includes it. Write
answers to the files in `/root/lab-answers/`.

## Tasks

1. Take a baseline (`nproc`, `uptime`, `free -h`, `vmstat 1 3`, `sar -u 1
   3`), and turn on sysstat's collection so that `sar` has history, now
   and at boot.
2. Something keeps a CPU busy. Find the service behind it, write its name
   to `/root/lab-answers/2`, and stop it for good.
3. Count context switches per process (`pidstat -w`). One process switches
   thousands of times a second while using little CPU: write its name (the
   command `pidstat` shows) to `/root/lab-answers/3`.
4. Find the unit that slowed the last boot most, and write its name to
   `/root/lab-answers/4`. Look at the critical chain too.

## Hints

- `systemctl enable --now sysstat`; on Ubuntu, also `ENABLED="true"` in
  `/etc/default/sysstat`.
- `vmstat 1 5`, `uptime`, `mpstat -P ALL 1 1`, `top`; `ps -o unit= -p
  PID`; `systemctl disable --now`.
- `pidstat -w 1 3`: the `cswch/s` column.
- `systemd-analyze blame`, `systemd-analyze critical-chain`.
