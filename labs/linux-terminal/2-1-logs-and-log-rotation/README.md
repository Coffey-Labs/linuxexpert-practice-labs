# Using Linux Terminal 2.1: Logs and log rotation

Reading `/var/log/auth.log` and the journal, rotating a log of your own
with logrotate, and filtering the journal by priority.

## Before you start

Work as root (`sudo -i`), and write answers to the files in
`/root/lab-answers/`. The lab creates user `alice`, who then runs four
commands with `sudo`, and it logs a few messages tagged `webapp` at
different priorities. It only checks that `/var/log/webapp` doesn't exist
yet; `le-lab reset` removes it and your logrotate file for it.

## Tasks

1. Find the last three commands `alice` ran with `sudo`, from
   `/var/log/auth.log` and from the journal, and write them to
   `/root/lab-answers/1`, one per line. Both should show the same commands
   at the same times.
2. Create `/var/log/webapp/access.log` with some lines in it, and a
   logrotate configuration that rotates it weekly, keeps 4 compressed
   copies, and creates a new empty log owned by `root:adm` with mode 640.
   Force one rotation.
3. Show only error messages (and worse) from the current boot, and write
   the `webapp` messages among them to `/root/lab-answers/3`.

## Hints

- `grep 'COMMAND=' /var/log/auth.log`, `journalctl -t sudo`; `tail -n 3`.
  Pasting whole log lines into the answer file is fine.
- A file in `/etc/logrotate.d/` with `weekly`, `rotate 4`, `compress` and
  `create 0640 root adm`; `logrotate -d` to test it, `logrotate -f` to
  force it. `zcat` reads the old copy.
- `journalctl -p err -b`; `-t webapp` narrows it to one tag.
