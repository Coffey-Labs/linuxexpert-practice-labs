# LFCA 1.1: Linux operating system

Finding out what system you're on, processes and PIDs, installing and
removing a package, and looking at the hardware.

## Before you start

Work as root (`sudo -i`). Answers go in `/root/lab-answers/<task>`, which
the lab creates. The lab starts a `sleep 6000` process in the background
for task 3. It notes whether `tree` is installed, and reset puts that back.

## Tasks

1. Find the distribution, its version and the kernel version. Write them
   to `/root/lab-answers/1`, one per line: the `ID` and `VERSION_ID` from
   `/etc/os-release`, then the output of `uname -r`.
2. Find the program running as PID 1 with `ps -ef | head`, and write its
   name to `/root/lab-answers/2`.
3. Find the PID of the lab's `sleep 6000` process with `ps`, write it to
   `/root/lab-answers/3`, and end the process with `kill`.
4. Install the package `tree`, run it, and list the files the package
   installed. Write the full path of the `tree` program from that list to
   `/root/lab-answers/4`. Then remove the package.
5. Look at the hardware with `lscpu`, `free -h`, `lsblk` and `lspci`.
   Write the number of CPUs that `lscpu` shows to `/root/lab-answers/5`.

## Hints

- `cat /etc/os-release`, `uname -r`.
- `ps -ef | head -n 3`; the `CMD` column.
- `ps -ef | grep sleep`, `pgrep -a sleep`, `kill PID`.
- `dnf install tree` / `apt install tree`, `rpm -ql tree` or
  `dpkg -L tree`, `dnf remove` / `apt remove`.
- The `CPU(s):` line of `lscpu`.
