# LFCS 3.6: Filesystem automounters

Mounting NFS shares and home directories on demand with autofs, idle
timeouts, and systemd's own automounting.

## Before you start

The lab adds a second machine, `nfs1` (`10.99.0.2`), running an NFS server
that exports to the lab network `10.99.0.0/24`:

- `nfs1:/srv/share`, with a file `hello.txt` in it;
- `nfs1:/export/home`, holding home directories for `alice` and `bob`
  (`/export/home/alice` and `/export/home/bob`, each with a `welcome.txt`).

`nfs1` shares this VM's files, so you can see the exported directories
here too, but mount them from `nfs1`. The lab creates users `alice` and
`bob` (password `Lab-Pass-1`) with the same UIDs as on the server, and
installs the NFS client tools. It also adds a 256 MiB spare disk,
`/dev/loop40`, that already holds an ext4 filesystem and comes back at every
boot before filesystems are mounted.

## Tasks

1. Automount `nfs1:/srv/share` at `/mnt/share` with autofs, using a direct
   map.
2. Automount every user's home directory from `nfs1:/export/home` under
   `/home/remote` with one wildcard line, and make `/home/remote/alice`
   alice's home directory.
3. Make autofs unmount idle shares after 30 seconds, for both maps.
4. Without autofs, make the filesystem on `/dev/loop40` mount at `/data`
   only when it's first used, set up in `/etc/fstab`.

## Hints

- `/etc/auto.master.d/*.autofs` (or `/etc/auto.master`) and map files;
  `systemctl reload autofs`; `findmnt -t autofs,nfs4`; `automount -m`.
- `*` and `&` in an indirect map; `usermod -d`; `su - alice`, `pwd`. The
  homes are private and root is squashed on the share, so look inside them
  as their owner.
- `--timeout=` in the master map.
- `x-systemd.automount` (and `x-systemd.idle-timeout`) in `/etc/fstab`;
  `systemctl daemon-reload`; `systemctl list-units --type=automount`.
