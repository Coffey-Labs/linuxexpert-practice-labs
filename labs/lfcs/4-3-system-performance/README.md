# LFCS 4.3: System performance and services

Finding the service behind a load, lowering its priority, reading boot
times, using sar, and finding an out-of-memory kill.

## Before you start

The lab starts a service that keeps one CPU busy, and adds two units that
slow the boot. **Reboot once** after setup, so that the last boot includes
them. It installs stress-ng and sysstat (with collection off), and makes the
journal persistent so that task 5's evidence survives a reboot. Write
answers to the files in `/root/lab-answers/`.

## Tasks

1. Find from the symptoms alone which service is causing the load, and
   write its name to `/root/lab-answers/1`. Leave it running.
2. Make that service run at nice 15 so it no longer slows other work, in a
   way that still holds after the service restarts.
3. Find which unit slowed the last boot most, and which one was on the
   critical path. Write the slowest unit on line 1 of
   `/root/lab-answers/3`, and the unit on the critical path on line 2.
4. Turn on sysstat collection, generate load for a while, and find the
   busiest interval of the day (the row of `sar -u` with the lowest
   `%idle`). Write its time to `/root/lab-answers/4`.
5. Trigger the OOM killer with a memory hog in a throwaway service
   (`systemd-run -p MemoryMax=100M -p MemorySwapMax=0 stress-ng --vm 1
   --vm-bytes 300M --timeout 60`) and find the evidence. Write the PID of
   the process it killed to `/root/lab-answers/5`.

## Hints

- `uptime`, `nproc`, `top`, `systemd-cgtop`, `ps -o unit= -p PID`.
- `Nice=` in a drop-in (`systemctl edit`); `ps -o ni=,comm= -C stress-ng`.
- `systemd-analyze blame`, `systemd-analyze critical-chain`.
- `systemctl enable --now sysstat` (on Debian and Ubuntu, also
  `ENABLED="true"` in `/etc/default/sysstat`), `sar -u`. Collection runs
  every 10 minutes; running `sa1 1 1` (in `/usr/lib64/sa/` or
  `/usr/lib/sysstat/`) adds a row now.
- `journalctl -k | grep -i 'killed process'`, `journalctl -u UNIT`.
