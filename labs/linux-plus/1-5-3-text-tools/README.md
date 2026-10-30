# Linux+ 1.5.3: Working with text

grep, cut, awk, sed, tr, sort and uniq on real files: users with a login
shell, a config file without its comments, an edit with sed, and a word
count.

## Before you start

The lab clears away the files the tasks create in `/tmp`, if they're there.
Ubuntu empties `/tmp` at boot, so do the tasks without a reboot. Tasks 1, 2
and 4 ask for findings: write them to the files in `/root/lab-answers/` that
they name.

## Tasks

1. Find the users with a UID from 1000 to 59999 (the regular users) with
   awk, and write their names, one per line, to `/root/lab-answers/1`.
2. Strip the comments and blank lines from `/etc/ssh/sshd_config`, saving
   what's left to `/tmp/sshd.active`, and count its lines in the same
   pipeline. Write the count to `/root/lab-answers/2`.
3. Copy `/etc/ssh/sshd_config` to `/tmp/s.conf`. With `sed -i.bak`, change
   the `PermitRootLogin` line (commented out or not) to
   `PermitRootLogin no`, keeping the original as `/tmp/s.conf.bak`, and
   compare the two with `diff`.
4. Find the most common word in the bash man page, and write it to
   `/root/lab-answers/4`.

## Hints

- `awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' /etc/passwd`.
- `grep -v -E '^\s*(#|$)'`, `tee`, `wc -l`. On the RHEL family only root
  can read `sshd_config`: `sudo`.
- `sed -i.bak 's/^#\?PermitRootLogin.*/PermitRootLogin no/'`.
- `man bash | tr -cs 'A-Za-z' '\n' | tr 'A-Z' 'a-z' | sort | uniq -c | sort -rn | head`.
