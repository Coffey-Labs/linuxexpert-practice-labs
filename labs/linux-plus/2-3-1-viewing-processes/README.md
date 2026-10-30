# Linux+ 2.3.1: Looking at processes

Process states, zombies and their parents, finding a busy process with the
sysstat tools, and tracing a program's system calls.

## Before you start

The lab installs sysstat and strace, and starts some processes for you to
find: one that is stopped, one whose child is a zombie, and one that keeps
a CPU core busy. It also installs a small program,
`/usr/local/bin/lab-report`. Write answers to the files in
`/root/lab-answers/`. Leave the processes running until you've checked.

## Tasks

1. Find the stopped process (state `T`), and write its PID to
   `/root/lab-answers/1`.
2. Find the zombie (state `Z`). Write the PID of its parent, the process
   that never collected it, to `/root/lab-answers/2`.
3. One process keeps a CPU core busy. Confirm it with `mpstat` and `pidstat`
   and write its PID to `/root/lab-answers/3`.
4. Trace `/usr/local/bin/lab-report` with strace to see which files it
   opens, and write the full path of the configuration file it reads to
   `/root/lab-answers/4`.

## Hints

- `ps -eo pid,ppid,stat,%cpu,%mem,cmd`, `pstree -ps PID`.
- `ps -eo pid,ppid,stat,cmd | grep '[d]efunct'`; the parent is the PPID.
- `mpstat -P ALL 1 3`, `pidstat 1 3`, `top`.
- `strace -f -e trace=openat COMMAND`.
