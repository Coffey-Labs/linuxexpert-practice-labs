# Linux+ 3.3.2: Permissions, attributes and ACLs

A team directory with setgid and the sticky bit, an immutable file, and an
ACL that lets one more user read a private file.

## Before you start

The lab creates user `pat` (password `Lab-Pass-1`), who stands in for you
in the chapter's commands: where they say `$USER` or `~`, use `pat` and
`/home/pat`. Group `labteam`, `/srv/team` and user `acltest` don't exist
yet: you create them. Try the umask commands of the chapter first if you
like; they aren't graded.

## Tasks

1. Create group `labteam`, add `pat` to it, and make `/srv/team` a team
   directory: group `labteam`, mode `3770` (setgid and sticky, no access
   for others). As `pat`, create a file `/srv/team/mine`; its group should
   be `labteam`, not pat's own group.
2. Create `/srv/team/locked` and make it immutable, so that even root
   can't delete it. Try, and look at its attributes. Leave it immutable.
3. Create user `acltest`. As `pat`, write `secret` to `/home/pat/acl.txt`
   with mode 600, and let others pass through pat's home directory
   (`o+x`). `acltest` can't read the file; give it read access with an
   ACL, so that it can, and nobody else can.

## Hints

- `groupadd`, `usermod -aG`, `chgrp`, `chmod 3770`, `ls -ld`;
  `sudo -u pat touch`.
- `chattr +i`, `lsattr`.
- On Ubuntu, `apt install acl` first. `setfacl -m u:NAME:r`, `getfacl`;
  `sudo -u acltest cat`.
