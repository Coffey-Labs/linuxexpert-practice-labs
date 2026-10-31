# EX294 2.1: ansible.cfg

Write a project's `ansible.cfg`, check what Ansible makes of it, and find
a setting that Ansible ignores.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) with an SSH key, and installs `ansible-core`. Work as greg.
His project `/home/greg/ansible` has an inventory, `inventory`, listing the
managed nodes, but no `ansible.cfg` yet. A second project,
`/home/greg/proj2`, has an `ansible.cfg` with a mistake in it.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers reached over SSH by name. On both, the automation
user `devops` accepts greg's key and may use sudo without a password. For
a root shell on a node, `sudo podman exec -it node1 bash`.

## Tasks

1. In `/home/greg/ansible`, write an `ansible.cfg` that uses `./inventory`,
   logs in as `devops`, puts roles in `./roles` and collections in
   `./collections`, and becomes root with sudo without asking for a
   password. `ansible-config dump --only-changed` shows each setting with
   your file's path, and `ansible all -a whoami` prints `root` for every
   node.
2. Set `forks` to 10 in the same file, so `ansible-config dump | grep
   FORKS` shows 10.
3. One setting in `/home/greg/proj2/ansible.cfg` is misspelled, so Ansible
   ignores it. Find it with `ansible-config dump --only-changed` (run in
   `/home/greg/proj2`) and correct it, so every setting in that file
   takes effect.

## Hints

- `[defaults]`: `inventory`, `remote_user`, `roles_path`,
  `collections_path`, `forks`, `host_key_checking`.
- `[privilege_escalation]`: `become`, `become_method`, `become_user`,
  `become_ask_pass`.
- `ansible --version` names the config file in use; Ansible only reads
  `./ansible.cfg` from the directory you run it in.
- `ansible-config init --disabled` lists every setting's correct name.
