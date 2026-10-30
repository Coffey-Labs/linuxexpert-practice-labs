# LPIC-1 108.1: Maintaining system time

Which NTP client runs, the hardware clock, and chrony's sources.

## Before you start

The lab notes which NTP client runs now, and saves chrony's configuration
(if chrony is installed) so reset can put it back. Changing the NTP sources
needs the VM to reach the internet on UDP port 123 to see them work, but the
check doesn't depend on that.

## Tasks

1. Run `timedatectl` and find out which NTP client the VM uses
   (`systemctl status chronyd chrony systemd-timesyncd`). Write the name of
   its service to `/root/lab-answers/1`.
2. Compare `sudo hwclock` with `date -u`. Then read `/etc/adjtime`, if it
   exists. Write `utc` or `local` to `/root/lab-answers/2`: the time the
   hardware clock keeps.
3. Install chrony if it isn't there (it replaces timesyncd), and read
   `chronyc sources -v` and `chronyc tracking`. Then change chrony's
   sources to just the pool `pool.ntp.org`, restart it, and watch the
   sources change with `chronyc sources`.

## Hints

- `systemctl is-active chronyd chrony systemd-timesyncd`.
- The third line of `/etc/adjtime` says `UTC` or `LOCAL`; without the file,
  the hardware clock is taken to be UTC. `timedatectl` shows it as "RTC in
  local TZ".
- `/etc/chrony.conf` on the RHEL family; `/etc/chrony/chrony.conf` and its
  `sources.d` directory on Debian and Ubuntu. Comment out the other `pool`
  and `server` lines. `chronyc -N sources` shows the names.
