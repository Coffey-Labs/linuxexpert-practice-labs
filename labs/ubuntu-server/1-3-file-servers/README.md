# Ubuntu Server 1.3: File servers: NFS and Samba

An NFS export for one client, mounted at boot, with root squashed, and a
Samba share for one group.

## Before you start

The lab adds a second machine, `peer` (`10.99.0.2`), linked to this VM's
lab address `10.99.0.1` on interface `le-host`.

- **NFS:** this VM is both s1, the server, and s2, the client: it mounts
  its own export through `10.99.0.1`, the way another machine would, so
  the server sees the client as `10.99.0.1`. That's s2's address here.
  The traffic never leaves the VM. The lab orders the NFS server before
  network mounts, so the mount comes up at boot and goes down first at
  shutdown.
- **Samba:** the peer is s2, the client. Run its commands with `sudo ip
  netns exec lepeer`, for example `sudo ip netns exec lepeer smbclient
  //10.99.0.1/docs -U dana -c ls`. Its traffic comes in over `le-host`, so
  open the firewall for Samba if it's running.

The lab installs `smbclient`, and creates users `pat` (the same UID on
both machines, since they share their users), `dana` (in group `docs`)
and `eli` (not in it), all with password `Lab-Pass-1`.

## Tasks

1. On s1, export `/srv/projects` read-write to s2 (`10.99.0.1`) only. On
   s2, mount it from `10.99.0.1` at `/mnt/projects` at every boot.
   `showmount -e 10.99.0.1` lists `/srv/projects` with that address, and
   `findmnt /mnt/projects` shows type `nfs4`.
2. Make the export writable for `pat`, but not for root on s2. As pat,
   `touch /mnt/projects/f` works and `ls -l /srv/projects` shows the file
   as pat's; `sudo touch /mnt/projects/x` fails with "Permission denied",
   because root counts as nobody.
3. On s1, share `/srv/samba/docs` as `docs`, writable only by members of
   the Linux group `docs`, and give the member `dana` the Samba password
   `Lab-Pass-1`. `testparm -s` shows the `[docs]` section; from the peer,
   dana can list the share and put a file there, and `eli` (who has no
   Samba password) gets `NT_STATUS_ACCESS_DENIED`.

## Hints

- `apt install nfs-kernel-server`; `/etc/exports` (no space before the
  parentheses), `exportfs -ra`, `exportfs -v`, `showmount -e`; a line in
  `/etc/fstab` with `_netdev`, then `systemctl daemon-reload`, `mount -a`.
- `root_squash` is the default; `chown`, `chmod 755`; `su - pat`.
- `apt install samba`; a `[docs]` section with `path`, `valid users =
  @docs`, `read only = no`; `chgrp docs`, `chmod 2770`; `smbpasswd -a`,
  `pdbedit -L`, `testparm -s`, `systemctl restart smbd`. `ufw allow
  Samba`.
