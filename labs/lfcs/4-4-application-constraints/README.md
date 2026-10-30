# LFCS 4.4: Application and service constraints

Open-file limits for a service, what a running program uses, cgroup caps,
login limits, and a privileged port for a non-root service.

## Before you start

The lab installs nginx (running, on port 80) and lsof, and creates user
`alice` (password `Lab-Pass-1`). It adds `heartbeat.service`, a small
looping service like the one you wrote in 4.2, and `webapp.service`, which
should serve `/srv/webapp` on port 81 as system user `webapp` but fails to
start. Write answers to the files in `/root/lab-answers/`.

## Tasks

1. Give nginx a limit of 65536 open files that survives package updates and
   reboots.
2. List every file, port and library the running nginx is using, and save
   the list in `/root/lab-answers/2` (command output is fine).
3. Cap `heartbeat.service` at 200 MiB of memory and 20% of one CPU.
4. Give user `alice` a hard limit of 200 processes.
5. Make `webapp.service` run as the non-root user `webapp` but listen on
   port 81, a privileged port (nginx already has port 80), also after a
   reboot.

## Hints

- `systemctl edit nginx`, `LimitNOFILE=`,
  `grep 'open files' /proc/$(pgrep -o nginx)/limits`.
- `lsof -p`, `ss -tlnp`, `ldd`, `ls -l /proc/PID/fd`.
- `systemctl set-property`, `MemoryMax=`, `CPUQuota=`,
  `systemctl show -p MemoryMax -p CPUQuotaPerSecUSec`.
- `/etc/security/limits.d/`; `ulimit -Hu` in a new login as alice
  (`su - alice`).
- `journalctl -u webapp`, `AmbientCapabilities=CAP_NET_BIND_SERVICE`,
  `ss -tlnp 'sport = :81'`.
