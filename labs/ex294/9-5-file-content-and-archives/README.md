# EX294 9.5: File content and archives

Change one line of a file whatever it says now, keep a block of lines up
to date, and archive a directory on every node and fetch the archives.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) with an SSH key, and installs `ansible-core`. Work as greg,
in `/home/greg/ansible`: its `ansible.cfg` reads the inventory `inventory`,
logs in as `devops` and becomes root. `node1` is in the group `webservers`
and `node2` in `dbservers`. The `community.general` collection isn't
installed yet.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers, prepared as in chapter 3.1: `devops` takes greg's
key and may use sudo without a password. Their `/etc/ssh/sshd_config`
files say different things about `PermitRootLogin`. (Drop-ins of the
node image in `/etc/ssh/sshd_config.d/` still allow root logins, and they
win over `sshd_config`, so `sshd -T` keeps saying `permitrootlogin yes`;
leave them.) For a root shell on a node, `sudo podman exec -it node1
bash`.

## Tasks

1. Write `/home/greg/ansible/sshd.yml` to set `PermitRootLogin no` in
   `/etc/ssh/sshd_config` on every node, whatever the line says now, and
   restart sshd only if it changed. `grep ^PermitRootLogin` shows one
   line, and a second run doesn't restart sshd.
2. Add this three-line block to `/etc/motd` on every node, between
   markers:

   ```
   This node is managed by Ansible.
   Changes made by hand will be lost.
   Questions: ops@lab.example
   ```

   Then change the last line to `Questions: admin@lab.example` and run it
   again. The file has one block, with the new line, between the markers.
3. Archive `/etc` on every node as `/root/etc.tar.bz2`, and fetch them all
   to the control node, under `/home/greg/ansible/backups/`.
   `backups/node1/root/etc.tar.bz2` and the other exist, and `tar tjf`
   lists them.

## Hints

- `ansible.builtin.lineinfile` with a `regexp` that matches the line
  whatever its value, `validate: /usr/sbin/sshd -t -f %s`, and a handler
  for the restart.
- `ansible.builtin.blockinfile` finds its own block again by its markers.
- `ansible-galaxy collection install 'community.general:>=11,<12'`
  (12 and later need a newer ansible-core) for
  `community.general.archive` (`format: bz2`); `ansible.builtin.fetch`
  with `dest: backups/`. `tar tjf` here needs the `bzip2` package.
