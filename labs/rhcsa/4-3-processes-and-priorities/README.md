# RHCSA 4.3: Processes and scheduling priority

Finding and ending busy processes, starting a process with a nice value,
changing the nice value of a running one, and listing the processes using
the most memory.

## Before you start

The lab starts two `sha256sum /dev/zero` processes as root, each using a
whole CPU. Nothing in this lab survives a reboot: do it all in one boot.

## Tasks

1. Find the process using the most CPU with `top`, and end both of the
   lab's `sha256sum` processes.
2. As a normal user, start `sha256sum /dev/zero` with a nice value of 10,
   in the background, and leave it running.
3. As root, change that process's nice value to -5.
4. Save the PID, user and memory use of the five processes using the most
   memory to `/root/topmem.txt`: a header line and five process lines,
   largest first.

## Hints

- In `top`, `P` sorts by CPU and `k` kills; or `pgrep`, `kill`, `pkill`.
- `nice -n 10 sha256sum /dev/zero &`; `ps -o pid,ni,user,cmd -C sha256sum`.
- `renice -n -5 -p PID`; only root may lower a nice value.
- `ps -eo pid,user,%mem --sort=-%mem | head -n 6`.
