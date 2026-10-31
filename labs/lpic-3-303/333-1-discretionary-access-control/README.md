# LPIC-3 333.1: Discretionary access control

Setuid, setgid and the sticky bit, ACLs with masks and defaults, ACL
backups, extended attributes and file capabilities.

## Before you start

The lab creates the group `projects` and the users `alice` (in
`projects`) and `bob` (not in it), with the password `Lab-Pass-1`. Work in
`/srv/dac`, which doesn't exist yet. Install the ACL and extended
attribute tools (`acl`, `attr`) if they're missing.

## Tasks

1. Make `/srv/dac/id-suid`, a copy of `id` owned by `bob` with the setuid
   bit, so that when `alice` runs it her effective user is `bob`. Then
   remove the owner's execute bit and look at the mode.
2. Make a shared directory `/srv/dac/shared`, owned by root and group
   `projects`, mode 3770 (setgid and sticky). As `alice`, create
   `alice.txt` in it; add `bob` to `projects` and, as `bob`, create
   `bob.txt` and try to delete `alice.txt`. Then take `bob` out of
   `projects` again.
3. Make `/srv/dac/plan.txt`, owned by `alice` and group `projects`, mode
   640. Give `bob` read and write access with an ACL, then limit it with
   the mask so that `bob` can read the file but not write it.
4. Give the directory `/srv/dac/reports` a default ACL that gives `bob`
   read and group `projects` read and write, and create `reports/q3.txt`
   in it. Then remove the default ACL again.
5. Back up the ACLs of `reports` (recursively) and `plan.txt` to
   `/srv/dac/acl-backup.txt`, clear `plan.txt`'s ACL and restore it from
   the backup. Copy `plan.txt` to `plain-copy.txt` with a plain `cp` and to
   `full-copy.txt` keeping its ACL.
6. As `alice`, set the extended attribute `user.reviewed` to `2026-10-23`
   on `shared/alice.txt`. Give `id-suid` the file capability `cap_net_raw`
   (permitted and effective) and find where it's stored. Try the
   immutable flag on `plan.txt`, and take it off again.

## Hints

- `cp`, `chown`, `chmod 4755`, `chmod u-x`; `sudo -u alice ./id-suid`;
  `find ... -perm -4000`.
- `install -d -m 3770 -g projects`, `sudo -u alice touch`, `usermod -aG`,
  `gpasswd -d`.
- `setfacl -m u:bob:rw`, `setfacl -m m::r`, `getfacl`; `sudo -u bob cat`.
- `setfacl -m d:u:bob:r,d:g:projects:rw`, `setfacl -k`.
- `getfacl -R reports plan.txt > acl-backup.txt`, `setfacl -b`,
  `setfacl --restore=acl-backup.txt` (from `/srv/dac`); `cp` and `cp -a`.
- `setfattr -n user.reviewed -v ...`, `getfattr -d`, `getfattr -d -m -
  -e hex`; `setcap cap_net_raw=ep`, `getcap`; `chattr +i`, `lsattr`,
  `chattr -i`.
