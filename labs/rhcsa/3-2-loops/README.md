# RHCSA 3.2: Loops

Looping over the lines of a file, over files, over fields of
`/etc/passwd`, and over arguments.

## Before you start

The lab writes `/root/users.txt`: one user name per line, with some blank
lines, and one name (`dora`) that already exists. Write each script where
its task says and make it executable; the checks run them.

## Tasks

1. Write `/usr/local/bin/mkusers` that creates a user for each name in
   `/root/users.txt`, skipping users who already exist, and run it.
   Running it again must create no duplicates and print no errors other
   than "already exists".
2. Write `/usr/local/bin/bigfiles` that prints the name and size in bytes
   (`NAME SIZE`, one per line) of every regular file directly in `/etc`
   larger than 10000 bytes. Symbolic links don't count.
3. Write `/usr/local/bin/regular-users`: a loop that prints the login name
   and home directory (`NAME HOME`) of every user with a UID of 1000 or
   more, from `/etc/passwd`.
4. Write `/usr/local/bin/updown` that pings each host name given as an
   argument and prints `NAME up` or `NAME down` for each.

## Hints

- `while read -r name; do ...; done </root/users.txt`; `[ -z "$name" ]`
  and `continue`; `id "$name"`.
- `for f in /etc/*`, `[ -f "$f" ] && [ ! -L "$f" ]`, `stat -c %s`. Compare
  with `find /etc -maxdepth 1 -type f -size +10000c`.
- `while IFS=: read -r name pw uid gid gecos home shell`.
- `for h in "$@"`; `ping -c1 -W1 "$h" >/dev/null 2>&1`.
