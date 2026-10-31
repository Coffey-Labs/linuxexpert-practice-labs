# EX294 3.2: SSH keys for managed nodes

Make a key pair for the user who runs Ansible, put its public key on every
managed node with a playbook, and trust the nodes' host keys properly
instead of turning host key checking off.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`), who has no SSH key yet, and installs `ansible-core` and
`sshpass`. Work as greg, in `/home/greg/ansible`: its `ansible.cfg` reads
the inventory `inventory`, logs in as `devops`, becomes root, and has
`host_key_checking = false`.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers reached over SSH by name. On each, `devops` has the
password `Lab-Pass-1` and passwordless sudo, but no authorized keys; `root`
and `ansible` have the same password. For a root shell on a node,
`sudo podman exec -it node1 bash`.

## Tasks

1. As greg, create an Ed25519 key pair with no passphrase in the default
   place, `~/.ssh/id_ed25519`, mode 600.
2. Write `/home/greg/ansible/keys.yml`, a playbook that installs greg's
   public key for `devops` on every managed node, and run it (with `-k` the
   first time). Then `ssh devops@node1 true` doesn't ask for a password,
   and a second run of `keys.yml` reports `changed=0`.
3. Remove `host_key_checking = false` from `ansible.cfg`, delete greg's
   `~/.ssh/known_hosts` (SSH filled it in while checking was off), and
   put the nodes' host keys there with `ssh-keyscan` instead, so that
   `ansible all -m ping` works with no prompt.

## Hints

- `ssh-keygen -t ed25519 -N '' -f ~/.ssh/id_ed25519`.
- `ansible.posix.authorized_key` needs `ansible-galaxy collection install
  ansible.posix`; `ansible.builtin.file` and `lineinfile` do the same job.
- `lookup('ansible.builtin.file', '/home/greg/.ssh/id_ed25519.pub')` reads
  the key on the control node.
- `ssh-keyscan node1 node2 >> ~/.ssh/known_hosts`; the names in
  `known_hosts` must be the ones in the inventory.
