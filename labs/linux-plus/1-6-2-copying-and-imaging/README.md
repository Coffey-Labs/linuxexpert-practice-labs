# Linux+ 1.6.2: Copies, syncs and disk images

Mirroring a directory with rsync, pulling files from another machine over
SSH, and imaging a disk with dd.

## Before you start

The peer, at `10.99.0.2` (name `peer`), stands in for the other VM. It runs
its own sshd and shares this VM's files and users, so its `/etc` is this
VM's `/etc`. The lab creates user `alex` (password `Lab-Pass-1`) and adds a
small 64 MiB spare disk, `/dev/loop40` (the chapter's `vdb`), with a
filesystem on it. Several files go in `/tmp`, which Ubuntu empties at boot,
so do the tasks without a reboot and run `le-lab check` before you clean up.

## Tasks

1. Copy `/etc/ssh` into `/tmp/src` and mirror `/tmp/src/` to `/tmp/dst/`
   with rsync. Add a file `/tmp/src/ssh/new.txt` and delete
   `/tmp/src/ssh/moduli`, try a dry run, then mirror again so that
   `/tmp/dst` matches. Finally, copy `/tmp/src` (no trailing slash) into
   `/tmp/dst2/`, and see where it lands.
2. As `alex`, set up SSH keys so that alex can log in to the peer
   (`alex@10.99.0.2`) without a password, then pull a copy of the peer's
   `/etc/` into `/tmp/other-etc/` with rsync. Files only root can read are
   skipped with "Permission denied".
3. Image `/dev/loop40` into `/tmp/vdb.img` with dd and compare the two with
   `cmp`. Keep the image until you've run `le-lab check`.

## Hints

- `rsync -av SRC/ DST/`, `rsync -avn --delete`, `rsync -a SRC DST/`.
- `sudo -iu alex`, `ssh-keygen`. The peer shares alex's home directory, so
  adding the public key to `~/.ssh/authorized_keys` is enough
  (`ssh-copy-id` needs a password login, which may be turned off).
  `rsync -a alex@10.99.0.2:/etc/ /tmp/other-etc/`.
- `dd if=DISK of=IMAGE bs=4M status=progress`, `cmp DISK IMAGE && echo identical`.
