# RHCSA 9.1: Local user accounts

Creating a service account, moving a home directory, and deleting users
with and without their files.

## Before you start

The lab checks that there's no user `svcbak` or `carol` and that UID 2001
is free. Task 3 deletes the users the first two tasks create, so the lab
runs a small service, `le-lab-watch`, that notes their `/etc/passwd` lines
(and what's in `/home/carol2`) every second for the check. Do the tasks in
order, and look at the results of each before you go on.

## Tasks

1. Create a user `svcbak` with UID 2001, the comment `Backup account`, and
   no login shell.
2. Create a user `carol`, then move her home directory to `/home/carol2`
   with its files, and change her comment to `Carol Smith`.
3. Delete `carol` together with her home directory, and `svcbak` without
   it. Then find the files left behind in `/home` that belong to nobody,
   and write their paths, one per line, to `/root/lab-answers/3`.

## Hints

- `useradd -u -c -s /sbin/nologin`; `getent passwd svcbak`.
- `useradd`, `usermod -m -d`, `usermod -c`; `ls -a /home/carol2`.
- `userdel -r`, `userdel`; `find /home -nouser`.
