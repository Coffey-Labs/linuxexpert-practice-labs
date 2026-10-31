# EX294 3.1: Preparing managed nodes

Bootstrap an automation user on every managed node with one playbook, run
it again without changes, and reach a node by address.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`), who has no SSH key yet, and installs `ansible-core`. Work as
greg, in `/home/greg/ansible`: its `ansible.cfg` reads the inventory
`inventory`, logs in as `devops` and becomes root.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers with their own users and packages, reached over
SSH by name. On each, `root` and `ansible` have the password `Lab-Pass-1`;
`ansible` is in `wheel`, so sudo asks for that password. Nothing else is
set up there. For a root shell on a node, `sudo podman exec -it node1 bash`.

## Tasks

1. As greg, write `/home/greg/ansible/bootstrap.yml` and run it once with
   `-k`, so that every managed node has the user `devops` with a hashed
   password, passwordless sudo, and greg's public key. Then
   `ansible all -m ping` works without `-k`, and `ansible all -a id` shows
   `uid=0(root)`.
2. Make a second run of `bootstrap.yml` report `changed=0` on every node.
3. Point one inventory host at an address instead of a name with
   `ansible_host`, so `ansible HOST -m ping` reaches it.

## Hints

- `ssh-keygen -t ed25519`; `-k` needs `sshpass` on the control node.
- `remote_user: ansible` with `become: true` needs `-K` too; with
  `remote_user: root`, leave out `become`.
- `password_hash('sha512')`, `update_password: on_create`, a sudoers
  drop-in with `validate: /usr/sbin/visudo -cf %s`.
- `ansible.posix.authorized_key` needs `ansible-galaxy collection install
  ansible.posix`; `ansible.builtin.file` and `lineinfile` do the same job.
- `ansible-inventory --list` shows what Ansible makes of the inventory.
