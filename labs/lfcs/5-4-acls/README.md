# LFCS 5.4: ACLs

Giving extra users and groups access with access control lists, default
ACLs for new files, the mask, and copying files with their ACLs.

## Before you start

The lab creates these users (password `Lab-Pass-1`): `alice`, `bob` in
group `finance`, and `dana` and `eve` in group `devs`. It sets up:

- `/srv/reports`, group `finance`, with two reports in it;
- `/srv/project`, group `devs`, with files of the team, some of which
  already have ACLs;
- `/srv/shared/plan.txt`, which has an ACL entry giving `alice` read and
  write access, but someone has since run `chmod 640` on it.

The `acl` tools (`getfacl`, `setfacl`) are installed.

## Tasks

1. Give user `alice` read and write access to `/srv/reports` and the files
   in it, without changing their group or adding alice to it.
2. Make every new file in `/srv/project` writable by group `devs`, whatever
   the creator's umask.
3. `alice` can no longer write to `/srv/shared/plan.txt`, although her ACL
   entry says `rw-`. Find out why, and write the name of the ACL entry that
   causes it to `/root/lab-answers/3`. Then fix it without removing alice's
   entry.
4. Copy `/srv/project` to `/backup/project` with its ACLs (do this after
   task 2). Test it by comparing `getfacl -R .` run in each directory; on
   XFS the copy may list the same files in a different order.

## Hints

- `getfacl`, `setfacl -m u:NAME:PERMS`, `-R`, and capital `X`.
- `setfacl -d`; test with `sudo -u eve bash -c 'umask 077; touch FILE'`.
- `#effective:` in `getfacl`; `setfacl -m m::...`.
- `cp -a`, `rsync -aA` or `tar --acls`.
