# Ubuntu Server 2.1: PXE, autoinstall and cloud-init

Writing and checking a cloud-init user-data file and an autoinstall file.

Booting a new VM from the files, and the chapter's PXE task, need more
than one VM and aren't part of this lab: try them on your own VMs once the
files pass here.

## Before you start

The lab makes the directory `/root/cloud` for your two files. This VM
came from a cloud image, so `cloud-init` is already installed.

## Tasks

1. Write `/root/cloud/user-data` that creates a user `deploy` with your
   SSH public key and sudo rights, installs `htop`, and writes the text
   `built by cloud-init` to `/etc/motd`. Check it: `sudo cloud-init schema
   -c /root/cloud/user-data` says "Valid schema".
2. Write an autoinstall file `/root/cloud/autoinstall.yaml` for a server
   named `db1` with a user `dbadmin` (password hash made with `openssl
   passwd -6`), SSH installed with password logins off, the LVM layout,
   and the package `postgresql`. `sudo cloud-init schema -c` accepts it,
   it starts with `#cloud-config`, everything is under `autoinstall:` with
   `version: 1`, and the password is a `$6$` hash.

## Hints

- `#cloud-config` on the first line; `users:` with `name`, `groups:
  [sudo]` or `sudo: "ALL=(ALL) NOPASSWD:ALL"`, `shell`,
  `ssh_authorized_keys`; `packages:`; `write_files:` with `path` and
  `content`. `ssh-keygen` if you have no key yet; `cat ~/.ssh/id_ed25519.pub`.
- `autoinstall:` with `version: 1`, `identity:` (`hostname`, `username`,
  `password`), `ssh:` (`install-server`, `allow-pw`), `storage:` `layout:`
  `name: lvm`, `packages:`. Quote the hash: it contains `$`.
