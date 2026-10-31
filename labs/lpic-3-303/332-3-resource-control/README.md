# LPIC-3 332.3: Resource control

Limits with `ulimit`, `prlimit` and pam_limits, a cgroup made by hand,
and the same controls through systemd.

## Before you start

The lab creates the user `limited` (password `Lab-Pass-1`). Your hand-made
cgroup in task 2 lives only until the next reboot, so check before you
reboot.

## Tasks

1. With pam_limits, give `limited` a soft limit of 100 open files, a hard
   limit of 200 open files, and a hard limit of 50 processes, in a file in
   `/etc/security/limits.d/`. Check them from a login shell as `limited`.
   Try `ulimit` and `prlimit` on your own shell and commands too.
2. Make a cgroup `/sys/fs/cgroup/lab` by hand with a memory limit of 50M,
   no swap, and a limit of 5 tasks. Run Python inside it so that both
   limits bite: an allocation that the OOM killer stops, and forks that
   are refused. Leave the cgroup in place, with its counters, for the
   check.
3. Give a slice of your own, `lab.slice`, `TasksMax=20` and
   `MemoryHigh=100M` with `systemctl set-property`, run a transient service
   in it, and read the settings back. Try `MemoryMax` on a scope and
   `CPUQuota` on a service with `systemd-run` as well.

## Hints

- A line is `user type item value`, e.g. `limited soft nofile 100`;
  `sudo -i -u limited bash -c 'ulimit -Sn; ulimit -Hn; ulimit -Hu'`.
  `ulimit -a`, `prlimit --nofile=8:8 COMMAND`, `/proc/PID/limits`.
- `mkdir /sys/fs/cgroup/lab`, then write `memory.max`, `memory.swap.max`
  and `pids.max`; move a shell into it with `echo $$ > cgroup.procs`.
  `python3 -c "x = bytearray(200 * 1024 * 1024)"`; a loop of `os.fork()`.
  `memory.events`, `pids.events`.
- `systemctl set-property lab.slice ...`, `systemd-run --unit=NAME
  --slice=lab.slice sleep 60`, `systemctl show lab.slice -p TasksMax -p
  MemoryHigh`; `systemd-run --scope -p MemoryMax=50M`, `-p CPUQuota=20%`;
  `systemd-cgls`, `systemd-cgtop`.
