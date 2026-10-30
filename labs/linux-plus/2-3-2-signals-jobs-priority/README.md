# Linux+ 2.3.2: Signals, jobs and priority

Sending signals by name and pattern without hitting the wrong process, and
changing a running process's priority.

## Before you start

The lab creates user `alice` (password `Lab-Pass-1`) and starts three of
her processes: `sleep 1000`, `sleep 1001`, and `yes` running at nice 15.
The chapter's job control (step 1) and `ulimit` (step 4) steps work in your
own shell and aren't graded; try them anyway.

## Tasks

1. Look at alice's sleep processes with `pgrep -a`. Stop `sleep 1000` with
   a signal, and leave `sleep 1001` running. (`pkill -f 'sleep 100'` would
   match both.)
2. Lower the priority of alice's `yes` process to nice 19. Then, as alice,
   try to set it back to 0 and see that it's refused.

## Hints

- `pgrep -a sleep`, `pgrep -fx 'sleep 1000'`, `kill PID`, `pkill -x`/`-f`
  with an anchored pattern such as `'^sleep 1000$'`.
- `ps -o pid,ni,%cpu,cmd -p PID`, `renice -n 19 -p PID`; `su - alice`.
