# LPIC-1 103.7: Searching text with regular expressions

Filtering out comments, pulling addresses out of a log, editing a copy of
a file with `sed`, and basic against extended regular expressions.

## Before you start

The lab creates `/root/regex/access.log`, a log with IPv4 addresses in it.
Work as root (`sudo -i`), and write answers to the files in
`/root/lab-answers/`.

## Tasks

1. Show `/etc/ssh/sshd_config` without comments or blank lines, first with
   two `grep -v` commands, then with one `grep -Ev '^(#|$)'`. Save the
   result in `/root/regex/sshd-active.txt`.
2. Pull every IPv4 address out of `/root/regex/access.log` with `grep -Eo`
   and count each one. Write the counts, as `uniq -c` prints them, to
   `/root/lab-answers/2`.
3. Copy `/etc/ssh/sshd_config` to `/root/sshd_config`, then use `sed
   -i.bak` on the copy to set the port to 2222, and compare the two files
   with `diff`.
4. Write the same pattern as a basic and an extended regex, and check both
   give the same matches in `/root/regex/access.log`. Write the basic one
   on line 1 of `/root/lab-answers/4` and the extended one on line 2.

## Hints

- `grep -v '^#' FILE | grep -v '^$'`.
- `grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' FILE | sort | uniq -c`.
- The port line may be commented out (`#Port 22`):
  `sed -i.bak 's/^#\?Port .*/Port 2222/'`. `diff FILE.bak FILE`.
- In a basic regex `\{`, `\(`, `\|` and `\+` do what `{`, `(`, `|` and
  `+` do in an extended one.
