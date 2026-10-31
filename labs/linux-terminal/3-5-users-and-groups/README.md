# Using Linux Terminal 3.5: Users and groups

Creating a user with useradd, adding groups, locking an account, and
removing one and finding what it left behind.

## Before you start

Work as root (`sudo -i`), and write answers to the files in
`/root/lab-answers/`. The lab checks that user `hana`, UID 1500 and group
`qa` don't exist yet. It creates user `lou`, who has files outside his
home directory. Task 4 removes `lou` rather than `hana`, so that hana stays
for grading. `le-lab reset` removes hana, `qa` and lou's files.

## Tasks

1. With useradd, create `hana` with a home directory, bash, the comment
   "Hana Ito" and UID 1500, in a new group `qa` as well as her own. Set her
   a password.
2. Add hana to `adm` without removing her from `qa`.
3. Stop hana logging in by any means, without deleting anything: `passwd
   -S hana` shows `L`, `chage -l hana` shows an account expiry date in the
   past, and `su - hana` fails.
4. Remove `lou`'s account and home directory, then find anything he left
   on the root filesystem, and write the paths to `/root/lab-answers/4`.

## Hints

- `groupadd`; `useradd -m -s -c -u -G`; `passwd`; check with `getent
  passwd hana`, `id hana`, `passwd -S hana`.
- `usermod -aG`: without `-a`, `-G` replaces the list.
- `usermod -L` (or `passwd -l`) locks the password only; `usermod -e 1` or
  `chage -E 0` expires the account, which also stops SSH keys.
- `userdel -r`, then `find / -xdev -nouser`.
