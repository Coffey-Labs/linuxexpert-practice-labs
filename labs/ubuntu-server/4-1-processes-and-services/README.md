# Ubuntu Server 4.1: Processes and services

A service's processes and who they run as, niceness, and signals.

## Before you start

The lab doesn't install anything: installing nginx is part of task 1. Do
task 2 as your own user, not root, and check before the `sleep` ends,
about 16 minutes after you start it. Nothing here lasts over a reboot, so
don't reboot before you check. Write answers to the files in
`/root/lab-answers/`.

## Tasks

1. Install nginx. Find its master process and its workers, the user each
   runs as, and the unit they belong to. Write the master's user to
   `/root/lab-answers/1-master`, the workers' user to
   `/root/lab-answers/1-workers`, and the unit to `/root/lab-answers/1-unit`.
2. As your own user, start `sleep 1000` in the background with niceness 5,
   then change it to 12, then try to set it back to 5 without sudo (that
   fails with "Permission denied").
3. Make nginx reread its configuration with a signal rather than
   `systemctl`: the master keeps its PID and the workers get new ones. Then
   stop it so that it stays stopped.

## Hints

- `ps -C nginx -o pid,ppid,user,unit,cmd`, `pgrep -a nginx`,
  `systemctl status nginx`.
- `nice -n 5 sleep 1000 &`, `renice -n 12 -p PID`, `ps -o ni= -p PID`.
- `sudo kill -HUP` of the master PID (`systemctl show -p MainPID nginx`),
  then `pgrep -a nginx`; `sudo systemctl stop nginx`, `systemctl
  is-active nginx`.
