# LFCS 3.4: Remote filesystems and network block devices

An NFS server and client, `root_squash`, a Samba share mounted with a
credentials file, and an iSCSI target and initiator.

## Before you start

The lab adds a second machine, `peer` (`10.99.0.2`), linked to this VM's
lab address `10.99.0.1`; together they make the lab network `10.99.0.0/24`.
This VM plays both roles in each task: it's the server, and it's also the
client, mounting its own shares through `10.99.0.1` the way another machine
on the lab network would. The traffic never leaves the VM, so no firewall
rules are needed.

The lab also creates:

- user `alice` (password `Lab-Pass-1`) and a directory `/srv/samba` she
  owns, with a file `readme.txt` in it;
- a 1 GiB disk image, `/var/lib/le-lab/iscsi/disk0.img`, the spare disk for
  the iSCSI target. Serve it as a file (a fileio backstore). It isn't
  attached as a loop device on purpose: the VM would then see the same
  filesystem twice, once there and once on the iSCSI disk.

Because the servers and the clients are the same machine, the lab orders
the NFS, Samba and iSCSI target services before network mounts: the mounts
are made after the servers start, and at shutdown they're unmounted (and
the iSCSI session logged out) before the servers stop.

## Tasks

1. Export `/srv/share` read-write to the lab network only (`10.99.0.0/24`),
   and mount it from `10.99.0.1` at `/mnt/share` at every boot. Make
   `/srv/share` writable for the test, for example `sudo chmod 1777
   /srv/share`.
2. Show what `root_squash` does: as root on the client, create
   `/mnt/share/rootfile`, then look at who owns `/srv/share/rootfile` on the
   server.
3. Share `/srv/samba` with Samba as `projects`, for user `alice`, and mount
   `//10.99.0.1/projects` at `/mnt/projects` at every boot, with a
   credentials file `/root/.smbcred` that only root can read.
4. Make the disk image an iSCSI target, connect to it from `10.99.0.1` as
   the initiator, logging in at every boot, and mount an XFS filesystem from
   the iSCSI disk at `/mnt/iscsi` at every boot.

## Hints

- `/etc/exports` (no space before the parentheses), `exportfs -ra`,
  `exportfs -v`, `showmount -e`; `_netdev` in `/etc/fstab`.
- `ls -l` on the server; `nobody` is UID 65534.
- `smb.conf`, `smbpasswd -a`, `testparm`, `smbclient -L`; on RHEL, SELinux
  wants the share labeled `samba_share_t` (`semanage fcontext`,
  `restorecon`). `chmod 600`; `credentials=` in `/etc/fstab`.
- `targetcli` (`backstores/fileio`, `iscsi/`, `luns`, `acls`, `saveconfig`);
  the ACL must name the initiator in `/etc/iscsi/initiatorname.iscsi`.
  `iscsiadm -m discovery`, `--login`, `node.startup`; `lsblk`, `blkid`.
