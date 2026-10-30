# RHCSA 6.2: Mounting NFS

Finding an NFS server's exports, mounting one by hand, and mounting it at
every boot.

## Before you start

The lab adds a second machine, `server` (`10.99.0.2`), running an NFS
server that exports `/exports/share` and `/exports/homes`. There's a file
`readme.txt` in `/exports/share` with a secret word in it. `server` shares
this VM's files, so you could read the directory here too, but the tasks
are about mounting it from `server`. The lab installs the NFS client tools
(`nfs-utils`).

## Tasks

1. List `server`'s exports from this VM, and save the list in
   `/root/lab-answers/1`.
2. Mount `server:/exports/share` on `/mnt/nfs` by hand, read `readme.txt`
   there, write the secret word from it to `/root/lab-answers/2`, and
   unmount it.
3. Mount `server:/exports/share` on `/mnt/nfs` at every boot.

## Hints

- `showmount -e server`; `>` saves a command's output.
- `mkdir -p /mnt/nfs`, `mount -t nfs`, `findmnt /mnt/nfs`, `umount`.
- A line in `/etc/fstab` with `_netdev`, then `systemctl daemon-reload` and
  `mount -a`.
