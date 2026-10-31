# Ubuntu Desktop 5.3: ACLs

Giving one extra user and one group access to a shared folder with ACLs,
default ACLs for new files, and copying a file with its ACL.

## Before you start

The lab creates users `alice` and `bob` (password `Lab-Pass-1`) and group
`designers`, with bob in it, as the chapter does. It installs the `acl`
tools (`getfacl`, `setfacl`) if they're missing. `/srv/shared` doesn't
exist yet.

## Tasks

1. Create `/srv/shared`, owned by you (your login user, or root) with mode
   750, where alice can list and read files and the group designers can
   also create them.
2. Make every file created in `/srv/shared` from now on readable and
   writable by designers and readable by alice.
3. As bob, create `/srv/shared/new`. Then copy it to `/tmp` so that its
   ACL comes along (it belongs to bob, so use sudo). Ubuntu empties `/tmp`
   at every boot, so do this task last and check it before you reboot.

## Hints

- `setfacl -m u:alice:rx,g:designers:rwx`; `getfacl -c` shows the entries
  and the mask. `sudo -u bob touch /srv/shared/t` should work and `sudo -u
  alice touch /srv/shared/t2` should be denied.
- Default entries: `setfacl -d -m ...`. Test with `sudo -u bob touch
  /srv/shared/new` and `getfacl -c /srv/shared/new` (look at
  `#effective:`).
- `cp -a`, or `cp --preserve=all`; `ls -l` shows a `+` after the
  permissions of a file with an ACL.
