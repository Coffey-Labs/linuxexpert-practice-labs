# LPIC-1 105.2: Writing simple scripts

Tests and exit codes, a script that mails root, loops and `case`.

## Before you start

The lab puts the chapter's `diskcheck` script in
`/usr/local/sbin/diskcheck`. It sets aside root's mailbox, if there is
one, so the check sees only new mail. Write your scripts in `/root`, start
each with a `#!` line, and make them executable.

## Tasks

1. Write `/root/checkfiles.sh`, which takes any number of file names and
   prints one line for each: the name and whether it's `missing`, a
   `directory` or a `readable` file. It exits with status 1 if any were
   missing, and 0 otherwise.
2. Install a mail client and a local MTA (Postfix), then run
   `/usr/local/sbin/diskcheck 5` as root and read root's mail.
3. Write `/root/count.sh`, which prints the numbers 1 to 10, one per line,
   with a `while` loop and a counter (the chapter's `for i in $(seq 1 10)`
   rewritten).
4. Write `/root/service.sh`, a `case` script that accepts `start`, `stop`
   and `status` (printing what it would do), and prints a usage message for
   anything else, including no argument.

## Hints

- `"$@"`, `[ -e ]`, `[ -d ]`, `[ -r ]`, `exit 1`; test with `echo $?`.
- The mail client is `s-nail` on the RHEL family and `mailutils` on Debian
  and Ubuntu; it gives you `mail`. Postfix needs to be running. `mail` with
  no arguments reads your mailbox.
- `i=1`, `while [ "$i" -le 10 ]`, `i=$((i + 1))`.
- `case "$1" in start) ... ;; *) echo "usage: ..." ;; esac`; then
  `bash -x /root/service.sh start` to follow it step by step.
