# LPIC-1 103.5: Creating, watching and killing processes

Job control, a `tmux` session that outlives your login, signalling
processes by name, and finding the biggest memory users.

## Before you start

The lab installs `tmux` if it's missing. Write answers to the files in
`/root/lab-answers/`. Running processes don't survive a reboot, so check
before you reboot.

## Tasks

1. Start `sleep 600`, suspend it with Ctrl-Z, list it with `jobs`, resume
   it with `bg`, bring it back with `fg`, and end it with Ctrl-C. Check it
   yourself: `jobs` shows it as Stopped, then Running.
2. Start a `tmux` session, run `top` in it, detach, log out, log back in
   and reattach. Leave `top` running in the session.
3. Start `sleep 1000 &` three times, list them with `pgrep -a sleep`, and
   end them all with one `pkill`. Check it yourself: `pgrep -a sleep`
   prints nothing afterwards.
4. Use `ps -eo pid,%mem,comm --sort=-%mem | head` to find the five
   biggest memory users, and compare with `top` sorted by memory. Write
   their PIDs and names, biggest first, one per line, to
   `/root/lab-answers/4`.
5. Start a CPU-heavy loop in the background (`while :; do :; done &`),
   then run `watch -d uptime` and see the load average climb. Leave
   `watch` with Ctrl-C and end the loop with `kill %1`. Check it
   yourself: `jobs` is empty afterwards.

## Hints

- Ctrl-Z, `jobs`, `bg %1`, `fg %1`.
- `tmux`, `top`, Ctrl-B then `d` to detach, `tmux ls`,
  `tmux attach`.
- `pgrep -a`, `pkill sleep` (or `pkill -x sleep`).
- In `top`, Shift+M sorts by memory.
