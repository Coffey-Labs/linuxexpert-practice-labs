# LPIC-1 103.6: Process priorities

Sharing a CPU between niced processes, who may lower a nice value, and how
`nice` passes on to child processes.

## Before you start

The lab creates user `dana` (password `Lab-Pass-1`) and starts a long
`sleep` process owned by her at nice value 10. Write answers to the
files in `/root/lab-answers/`. The process doesn't survive a reboot, so
check before you reboot.

## Tasks

1. Start two CPU-heavy loops pinned to the same CPU, one at the default
   and one niced:
   `taskset -c 0 sh -c 'while :; do :; done' &` and
   `taskset -c 0 nice -n 19 sh -c 'while :; do :; done' &`.
   Watch their CPU share in `top`, then end them with `kill %1 %2`. Check
   it yourself: the niced loop gets only a few percent.
2. As `dana`, try to renice her `sleep` process from 10 to 5 and read
   the error. Then do it as root.
3. Run `nice` with no arguments, then `nice bash` and run `nice` again
   inside the new shell. Write what `nice` printed inside the new shell to
   `/root/lab-answers/3`.

## Hints

- `top` shows `NI` and `%CPU`; `q` quits.
- `su - dana` (or `sudo -iu dana`), `pgrep -u dana sleep`,
  `renice -n 5 -p PID`; `ps -o pid,ni,comm -u dana`.
- `nice` alone prints the current nice value; `nice CMD` adds 10.
