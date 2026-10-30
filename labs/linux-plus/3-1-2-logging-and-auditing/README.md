# Linux+ 3.1.2: Logging and auditing

A persistent journal, a tagged log message, a logrotate rule, and an audit
watch on a file.

## Before you start

The journal on this VM is kept in memory only, so it's lost at every
reboot (the lab moved any saved journal aside; reset puts it back). The lab
creates `/var/log/labapp/app.log`, a log file of a made-up application.
auditd runs on the RHEL family; on Ubuntu it isn't installed yet.

## Tasks

1. Make the journal persistent, so that it keeps messages across reboots.
   Check its size and the list of boots.
2. After task 1, log the message `hello journal` with the tag `labtest`, and
   find it in the journal by its tag.
3. Write a logrotate rule, `/etc/logrotate.d/labapp`, for
   `/var/log/labapp/*.log`: rotate daily, keep 3 old logs, compress them,
   and don't complain if a log is missing. Test it with a dry run, then
   force a rotation.
4. Watch `/etc/hosts` for writes and attribute changes with the audit key
   `hosts-change` (install `auditd` on Ubuntu first; on AlmaLinux 10,
   `auditctl` is in the `audit-rules` package). Touch the file, add a
   line to it, and find the events by their key. Then take the line out
   again and remove the watch.

## Hints

- `/var/log/journal`, `systemctl restart systemd-journald`; until the next
  boot, journald writes there only after `journalctl --flush`.
  `journalctl --disk-usage`, `journalctl --list-boots`.
- `logger -t`, `journalctl -t`.
- `logrotate -d` (dry run), `logrotate -f` (force).
- `auditctl -w FILE -p wa -k KEY`, `ausearch -k KEY -i`, `auditctl -W`.
