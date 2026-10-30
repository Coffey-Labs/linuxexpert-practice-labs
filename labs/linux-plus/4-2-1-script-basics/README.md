# Linux+ 4.2.1: Shell script basics

A script with arguments, a default value and exit codes, and parameter
expansion.

## Before you start

Work as root, so `~` is `/root`. The lab only checks that `~/info.sh`
doesn't exist yet. Write answers to the files in `/root/lab-answers/`.

## Tasks

1. Write the executable script `~/info.sh`: with `set -u`, it takes a host
   as its first argument (default: this machine's hostname), prints
   `Checking HOST (N args, script NAME, PID PID)`, then pings the host once
   with a one-second timeout and prints `up` and exits 0, or prints `down`
   and exits 1. Run it with no argument, with `192.0.2.1`, and with
   `bash -x` and `localhost`.
2. Set `f=/var/log/nginx/access.log` and, with parameter expansion only
   (no external commands), print on one line: the file name, the directory,
   the path with `.log` replaced by `.old`, the length of the path, and the
   path in capitals, separated by spaces. Save that line in
   `/root/lab-answers/2`.

## Hints

- `#!/bin/bash`, `${1:-$(hostname)}`, `$#`, `$0`, `$$`,
  `if ping -c1 -W1 "$host" >/dev/null 2>&1; then ...`, `chmod +x`,
  `echo "exit $?"`.
- `${f##*/}`, `${f%/*}`, `${f%.log}`, `${#f}`, `${f^^}`.
- The chapter's step 2 (export and subshells) isn't graded; try it anyway.
