# EX294 3.4: Deploying files to managed nodes

Copy a file from the project to the webservers with a backup, make a
directory and write a file from inline content, and fetch a file back from
every node.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) with an SSH key, and installs `ansible-core`. Work as greg,
in `/home/greg/ansible`: its `ansible.cfg` reads the inventory `inventory`,
whose group `webservers` holds both nodes, logs in as `devops` and becomes
root.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers reached over SSH by name. On each, `devops` has
greg's key and passwordless sudo, and `/etc/issue.net` is the old one,
owned by `ansible` with mode 0600. SELinux is off inside the nodes, so
`ls -lZ` shows no `etc_t` there. For a root shell on a node,
`sudo podman exec -it node1 bash`.

## Tasks

1. Deploy `/etc/issue.net` to the webservers from a file in your project
   (such as `files/issue`), owned by root, mode 0644, keeping a backup of
   the old one. Change the source and run it again: another backup
   appears.
2. On the webservers, create `/srv/app/conf` owned by `devops` with mode
   0750, and write `app.conf` inside it from inline content.
3. Fetch `/etc/hostname` from every webserver into `fetched/` in the
   project, so that `fetched/node1/etc/hostname` and
   `fetched/node2/etc/hostname` exist on the control node.

## Hints

- `ansible.builtin.copy` with `src`, `dest`, `owner`, `group`, `mode` and
  `backup: true`; `--diff` shows what changes.
- `ansible.builtin.file` with `state: directory`; `copy` with `content`.
- `ansible.builtin.fetch` with `dest: fetched/`.
- `ansible webservers -a 'stat -c "%U %a" /srv/app/conf'` and
  `ansible webservers -a 'ls -l /etc'` check your work.
