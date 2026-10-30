# LPIC-1 108.2: System logging

`logger` and the journal, an rsyslog rule, a persistent journal, and a
logrotate rule.

## Before you start

The lab makes the journal non-persistent: if `/var/log/journal` exists, it
moves it to `/var/log/journal.le-lab` (reset puts it back), so the journal
lives in `/run` and is lost at every reboot. Task 3 needs a reboot; do task
1 again afterwards if its message was lost with it.

## Tasks

1. Send a message with `logger -t test -p user.warning` and find it with
   `journalctl -t test` and, if rsyslog is installed, in `/var/log`.
2. Install rsyslog if needed, add a rule sending `local3.*` to
   `/var/log/local3.log`, restart it, and test with
   `logger -p local3.info`.
3. Check whether the journal is persistent with `ls /var/log/journal`. Make
   it persistent, reboot, and read the previous boot with
   `journalctl -b -1`.
4. As root, write a logrotate rule `/etc/logrotate.d/lrtest` for
   `/var/log/lrtest/test.log`, fill the log, and run `logrotate -d` and then
   `logrotate -f` on the rule, so that the log is rotated.

## Hints

- `journalctl -t test -p warning`; `grep test /var/log/syslog` or
  `/var/log/messages`.
- A file in `/etc/rsyslog.d/` ending in `.conf`; `rsyslogd -N1` checks the
  configuration.
- `Storage=persistent` in `/etc/systemd/journald.conf` (or a drop-in), or
  create `/var/log/journal`; `journalctl --list-boots`.
- `mkdir /var/log/lrtest`; a block with `rotate`, `size` or `daily`,
  `compress`, `missingok`; `logrotate -d /etc/logrotate.d/lrtest`.
