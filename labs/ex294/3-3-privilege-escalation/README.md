# EX294 3.3: Privilege escalation

Give the automation user passwordless sudo with a validated sudoers
drop-in, see `validate` stop a broken one, and run one task as another
user in a play that becomes root.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) with an SSH key, and installs `ansible-core` and `sshpass`.
Work as greg, in `/home/greg/ansible`: its `ansible.cfg` reads the
inventory `inventory`, logs in as `devops` and has `become = true`.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers reached over SSH by name. On each, `devops`
accepts greg's key but has no sudo rights yet, so `ansible all -a id`
fails for now. `root` and `ansible` (in `wheel`, so sudo asks for the
password) have the password `Lab-Pass-1`, as does `devops`. For a root
shell on a node, `sudo podman exec -it node1 bash`.

## Tasks

1. Write `/home/greg/ansible/sudo.yml`, which gives `devops` passwordless
   sudo on every managed node with a validated drop-in,
   `/etc/sudoers.d/devops`, mode 0440, and run it. Then
   `ansible all -a id` shows `uid=0(root)` on every node.
2. Copy it to `/home/greg/ansible/typo.yml` and put a typo in the rule
   (for example, leave out the colon after `NOPASSWD`). Running
   `typo.yml` must fail at `validate`, and sudo must still work on the
   nodes.
3. Write `/home/greg/ansible/whoami.yml`: a play with `become: true` whose
   `command: whoami` task has `become_user: devops` and prints `devops`
   for every node.

## Hints

- Until devops has sudo, log in as someone who has it: `remote_user: root`
  with `-k`, or `remote_user: ansible` with `-k -K`.
- `ansible.builtin.copy` with `content`, `mode: "0440"` and
  `validate: /usr/sbin/visudo -cf %s`; the rule needs its trailing newline.
- `register` the result and print `.stdout` with `debug`, or run the
  playbook with `-v`.
