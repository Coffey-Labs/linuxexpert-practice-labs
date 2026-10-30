# RHCSA 6.5: Fixing file permission problems

A shared group directory, a file one user can't reach, and what `chmod`
does to an ACL's mask.

## Before you start

The lab creates group `devs` with members `alice` and `bob`, and a third
user, `carol`, who isn't in it (password `Lab-Pass-1` for all three). It
also creates the directory `/srv/reports` (mode `750`, owned by root) with
an ACL entry that gives `bob` read and execute access.

## Tasks

1. Make a directory `/srv/devs` where every new file belongs to group
   `devs` and is writable by its members, and members can't delete each
   other's files.
2. As root, create `/srv/secret/f.txt` (mode `644`) in a directory
   `/srv/secret` with mode `700`. Find out why `bob` can't read it, then
   let only `bob` read it, without giving access to anyone else.
3. Run `chmod 700 /srv/reports` and look at `bob`'s ACL entry with
   `getfacl`. Write the effective permissions it shows to
   `/root/lab-answers/3`, then give `bob` his access back with
   `setfacl -m m::rx`.

## Hints

- `chgrp`, `chmod 3770` (or `g+s,o+t`), `setfacl -d -m g:devs:rw`;
  `ls -ld`, `getfacl`. Test as the users: `su - alice`, `sudo -u bob`.
- `namei -l /srv/secret/f.txt`; `setfacl -m u:bob:x` on the directory.
- `getfacl -c /srv/reports` shows `#effective:` next to masked entries.
