# LFCS 5.1: User and group accounts

Creating users and groups, password ageing, locking accounts, sudo rules,
and cleaning up after a removed user.

## Before you start

The lab creates group `webadmins` with member `wendy`, and user `dave`, who
owns a few files outside his home directory. Lab users' password is
`Lab-Pass-1`.

## Tasks

1. Create user `carol` with UID 2001, shell `/bin/sh`, a home directory,
   supplementary group `developers` (GID 3000), and an initial password
   that must be changed at first login.
2. Make every password of `carol` expire after 60 days, with a 10-day
   warning.
3. Lock `carol`'s password, then set the account to expire on 2026-12-31.
4. Let members of group `webadmins` restart and reload nginx with sudo
   (`systemctl restart nginx` and `systemctl reload nginx`), and nothing
   else. You don't need nginx installed for this.
5. Remove user `dave` and his home directory. Then find the files left on
   the system that belonged to him, and write their full paths, one per
   line, to `/root/lab-answers/5`.

## Hints

- `useradd -u ... -s ... -m -G ...`, `groupadd -g`, `chage -d 0`.
- `chage -M -W`, `passwd -l` or `usermod -L`, `chage -E`.
- A file in `/etc/sudoers.d/` checked with `visudo -cf`; `sudo -l -U wendy`.
- `userdel -r`, then `find / -xdev -nouser`.
