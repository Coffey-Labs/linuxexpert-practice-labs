# RHCSA 4.5: Logs and the journal

A persistent journal, filtering by unit, priority and time, writing to
the log with `logger`, and finding a failed `su`.

## Before you start

The lab keeps the journal in memory only (`Storage=volatile`, in
`/etc/systemd/journald.conf.d/00-le-lab.conf`), so it's lost at every
reboot. rsyslog still writes `/var/log/messages` and `/var/log/secure`.
Do task 1 first: messages sent before the journal is persistent are lost
at the reboot.

## Tasks

1. Make the journal persistent, reboot, and show the messages from the
   previous boot.
2. Save the sshd messages of priority err and above from the last hour
   to `/root/ssh-errors.txt` (it may only say `-- No entries --`).
3. Send a message with priority `warning` using `logger`, and find it in
   the journal and in `/var/log/messages`.
4. As a normal user, run `su -` and type a wrong password, then find the
   attempt in `/var/log/secure`.

## Hints

- `Storage=persistent` in a `journald.conf.d` file that sorts after
  `00-le-lab.conf` (or remove the lab's file and create `/var/log/journal`),
  then `systemctl restart systemd-journald`. `journalctl --list-boots`,
  `journalctl -b -1`.
- `journalctl -u sshd -p err --since "1 hour ago" --no-pager`.
- `logger -p user.warning "..."`; `journalctl -p warning -n 5`.
- `sudo grep "authentication failure" /var/log/secure`.
