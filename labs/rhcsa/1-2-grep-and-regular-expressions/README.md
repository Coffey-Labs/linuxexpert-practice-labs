# RHCSA 1.2: grep and regular expressions

Matching lines, dropping comments and blank lines, anchoring a pattern to
the end of a line, and counting matches.

## Before you start

The lab creates users `grace` and `henry` with the shell `/bin/bash`, and
user `ivan` with `/sbin/nologin`. Write the results of tasks 2 and 3 to
the files named there, so they can be checked.

## Tasks

1. As root, save every line of `/etc/services` that contains the string
   `ich` to `/root/ich.txt`, in the original order.
2. Show only the active settings of `/etc/ssh/sshd_config`, with no
   comments or blank lines (the file is readable only by root: use sudo).
   Save that output to `/root/lab-answers/2`.
3. List the login names of every user whose shell is `/bin/bash`, one per
   line, in `/root/lab-answers/3`.
4. Count how many lines of `/etc/passwd` contain `nologin`, and save the
   number to `/tmp/nologin-count.txt`.

## Hints

- `grep PATTERN FILE >FILE`.
- `grep -v`, `^#`, `^$`, or `grep -Ev '^(#|$)'`.
- `grep '/bin/bash$'` and `cut -d: -f1`, or `awk -F:`.
- `grep -c`.
