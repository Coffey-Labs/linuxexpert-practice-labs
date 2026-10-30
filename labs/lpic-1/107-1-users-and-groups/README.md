# LPIC-1 107.1: User and group accounts

Creating users and groups, supplementary groups, password ageing, system
accounts, and what deleting a user leaves behind.

## Before you start

The lab creates group `testers` and users `pat`, `ken` and `lou`. Their
password is `Lab-Pass-1`. `ken` owns a file outside his home directory.

## Tasks

1. Create group `developers`, and user `dana` with a home directory, the
   comment `Dana Lee`, the shell `/bin/sh` and the supplementary group
   `developers`. Read the new lines in `/etc/passwd`, `/etc/shadow` and
   `/etc/group`, and the new home directory.
2. Add `dana` to a second group, `testers`, with `usermod -aG`. Then run
   `usermod -G developers dana`, and write the name of the group she lost
   to `/root/lab-answers/2`.
3. Make `dana`'s password expire every 30 days, with a 7-day warning. Check
   with `chage -l` and the fields in `/etc/shadow`.
4. Force `pat` to change her password with `chage -d 0`, then log in as
   `pat` (on the console, or with `ssh pat@localhost`) and see what happens.
5. Create a system account `appsvc` with a `nologin` shell, and try
   `su - appsvc`.
6. Delete user `ken` with `userdel -r` and user `lou` without it. Then find
   the files they left behind with `find / -xdev -nouser`, and write those
   paths to `/root/lab-answers/6`, one per line.

## Hints

- `groupadd`, `useradd -m -c -s -G`, `getent passwd dana`, `ls -la`.
- `id dana` before and after; `-a` is what keeps the other groups.
- `chage -M -W`, `chage -l dana`; fields 5 and 6 of `/etc/shadow`.
- `chage -l pat` shows "password must be changed".
- `useradd -r -s` (the path of `nologin` is in `/etc/shells`, or try
  `command -v nologin`).
- `userdel` with and without `-r`; `find / -xdev -nouser 2>/dev/null`.
