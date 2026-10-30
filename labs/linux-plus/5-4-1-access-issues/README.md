# Linux+ 5.4.1: Permission, SELinux and account problems

A directory that blocks the way, an ACL mask, an attribute that stops
root, and an account that can't log in.

## Before you start

The lab creates user `permtest` (password `Lab-Pass-1`) and the files
`/srv/lab/inner/f.txt` and `/srv/lab/inner/old-report.txt`. It installs
the `acl` tools if they're missing. Several things stand in permtest's way.
Write answers to the files in `/root/lab-answers/`.

## Tasks

1. `permtest` can't read `/srv/lab/inner/f.txt`, although the file itself
   is readable by everyone. Find the path component that blocks it, write
   it to `/root/lab-answers/1`, and fix it so others can pass through,
   without giving them write access.
2. `f.txt` has an ACL entry giving `permtest` read and write access, but
   permtest still can't write to it. Find the ACL entry that limits it,
   write its name to `/root/lab-answers/2`, and fix it without removing
   permtest's entry.
3. Even root can't delete `/srv/lab/inner/old-report.txt`. Find out why,
   write the attribute's name to `/root/lab-answers/3`, and delete the
   file.
4. `permtest` can't log in at all. Find the two causes (`su - permtest`
   and `chage -l permtest` help) and fix them, so that permtest gets a
   bash shell again and its account never expires.

## Hints

- `namei -l PATH`, `chmod`.
- `getfacl`; the `mask` entry; `setfacl -m m::rw`.
- `lsattr`, `chattr -i`.
- `getent passwd permtest`, `usermod -s /bin/bash`, `chage -l`,
  `chage -E -1`.
