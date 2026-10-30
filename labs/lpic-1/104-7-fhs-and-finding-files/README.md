# LPIC-1 104.7: The FHS and finding files

Where a service's files live, the `locate` database and what it leaves
out, and the different ways to look up a command.

## Before you start

The lab installs `plocate` if it's missing, creates `/srv/archive/` with a
few old files in it, and builds the `locate` database. It saves
`/etc/updatedb.conf`; reset puts it back. Work as root (`sudo -i`), and
write answers to the files in `/root/lab-answers/`.

## Tasks

1. Take sshd. Find its program, configuration, logs, runtime files and man
   pages, and say why each lives where it does. Write one path (or
   command) per line to `/root/lab-answers/1`: the program, the main
   configuration file, where its log messages go, a runtime file under
   `/run`, and its man page.
2. Create a file, `locate` it, run `updatedb` as root, and `locate` it
   again. Delete it and compare `locate` with `locate -e`. Write which of
   the two still lists the deleted file to `/root/lab-answers/2`.
3. Add `/srv/archive` to `PRUNEPATHS` in `/etc/updatedb.conf`, run
   `updatedb`, and show that its files are no longer found.
4. Compare `which -a`, `type -a` and `whereis` for `ls`, `passwd` and
   `cd`. Write what `type -a cd` prints to `/root/lab-answers/4`.
5. Time `locate passwd` against `find / -name passwd 2>/dev/null` with
   `time`. Check it yourself: `locate` answers in milliseconds.

## Hints

- `command -v sshd`, `systemctl cat sshd` (`ssh` on Ubuntu), `ls /etc/ssh`,
  `journalctl -u`, `ls /run`, `man -w sshd`.
- `locate` searches a database that only `updatedb` refreshes; `-e`
  checks that each file still exists.
- `PRUNEPATHS` is a space-separated list in double quotes.
- `type` knows about builtins and aliases; `which` and `whereis` only
  about files.
