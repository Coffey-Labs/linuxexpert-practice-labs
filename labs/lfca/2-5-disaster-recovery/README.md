# LFCA 2.5: Disaster recovery

A backup with tar and a restore, and a mirror to another machine with
rsync over SSH.

## Before you start

Work as root (`sudo -i`). The lab creates the directories `/srv/projects`
and `/srv/site` with a few files, and user `alice` (password
`Lab-Pass-1`).

The peer, at `10.99.0.2` (name `peer`), stands in for a second VM. It runs
its own SSH server. It shares this VM's files and users, so what you copy
to `alice@peer:mirror/` lands in `/home/alice/mirror` here too, where you
can compare it. Get a shell there with `sudo ip netns exec lepeer bash`.

## Tasks

1. Back up `/srv/projects` to `/root/projects.tar.gz` with `tar`, delete
   `/srv/projects`, and restore it from the archive. Compare it with the
   original.
2. Install rsync if needed, and mirror `/srv/site` to the peer over SSH, as
   `alice`, into her home directory's `mirror` directory. Then change
   `/srv/site/index.html` and run it again, watching how little it copies.
3. Take a VM snapshot, delete something important, and roll back. Not
   graded.

## Hints

- `tar -czf /root/projects.tar.gz -C /srv projects`, `tar -tzf`,
  `rm -r`, `tar -xzf ... -C /srv`. Keep a list such as
  `find /srv/projects -type f | xargs sha256sum` from before to compare.
- `rsync -av /srv/site/ alice@peer:mirror/` (mind the trailing slashes);
  `--stats` or `-v` shows what it sent. `ssh-copy-id alice@peer` saves
  typing the password each time.
- Snapshots belong to the hypervisor (virt-manager, VirtualBox, your cloud
  console), not to the VM.
