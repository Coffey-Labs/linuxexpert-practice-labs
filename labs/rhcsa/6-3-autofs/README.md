# RHCSA 6.3: autofs

Mounting NFS exports on demand with an indirect map, a wildcard map for
home directories, and a direct map.

## Before you start

The lab adds a second machine, `server` (`10.99.0.2`), running an NFS
server that exports to the lab network `10.99.0.0/24`:

- `server:/exports/share`, with a file `readme.txt` in it;
- `server:/exports/homes`, with a home directory for each of `alice` and
  `bob` (`/exports/homes/alice` and `/exports/homes/bob`, each with a
  `welcome.txt`).

`server` shares this VM's files, so you can see `/exports` here too, but
mount it from `server`. The lab creates users `alice` and `bob` (password
`Lab-Pass-1`) and sets `alice`'s home directory to `/rhome/alice`. autofs
isn't installed.

## Tasks

1. Make `server:/exports/share` mount on demand at `/shares/data`,
   unmounting after 60 seconds unused.
2. Make each user's home mount on demand from `server:/exports/homes/USER`
   at `/rhome/USER`, with one map line, so that `su - alice` lands in
   `/rhome/alice`.
3. Make the same share, `server:/exports/share`, mount on demand at
   `/mnt/direct` with a direct map, still after a reboot.

## Hints

- `dnf install autofs`, `systemctl enable --now autofs`; a file in
  `/etc/auto.master.d/` ending in `.autofs`, and a map file;
  `systemctl reload autofs`.
- `/shares  /etc/auto.shares  --timeout=60`, and a `data` line in the map.
- `*` and `&` in the map line. The homes are private and root is squashed
  on the share, so look inside them as their owner: `su - alice`.
- `/-` in the master map; full paths in a direct map.
- `ls`, `findmnt`, `automount -m`.
