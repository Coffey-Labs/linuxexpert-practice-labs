# Linux+ 2.2.1: Users and groups

Reading the account files, a skeleton directory, a user, a group and a
service account, and the `usermod -G` trap.

## Before you start

The lab only checks that `labuser`, `labsvc`, `labgroup` and
`/etc/skel/bin` don't exist yet; it doesn't create anything. Write answers
to the files in `/root/lab-answers/`. Don't run the chapter's clean-up
step: `le-lab reset` does it.

## Tasks

1. Find the lowest UID that `useradd` gives a normal user on this system,
   and write it to `/root/lab-answers/1`.
2. Add a directory `bin` to `/etc/skel`. Then create user `labuser` with
   the comment `Lab User`, shell `/bin/bash` and a home directory (which
   should get the `bin` directory); a group `labgroup` with `labuser` as a
   member; and a system account `labsvc` with no home directory that can't
   log in.
3. Add `labuser` to the administrators' group (`wheel` on RHEL relatives,
   `sudo` on Debian and Ubuntu), then run `usermod -G labgroup labuser` and
   see what happens to that membership. Finish with `labuser` in both
   groups.

## Hints

- `/etc/login.defs`: `UID_MIN`, `SYS_UID_MAX`.
- `useradd -m -c -s`, `groupadd`, `usermod -aG`, `useradd -r -M -s
  /sbin/nologin`; `id`, `getent passwd`.
- `-G` without `-a` replaces the list of supplementary groups.
