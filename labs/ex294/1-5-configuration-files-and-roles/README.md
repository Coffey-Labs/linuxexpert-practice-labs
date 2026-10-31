# EX294 1.5: Configuration files and roles

Find which `ansible.cfg` Ansible reads, list what it changes, and write a
small role.

## Before you start

This VM is the control node. The lab installs `ansible-core` and creates
the user `greg` (password `Lab-Pass-1`), who has an SSH key. Work as greg
(`su - greg` as root), in `/home/greg/ansible`: its `ansible.cfg` reads the
inventory `inventory`, which has `node1` and `node2` in the group `nodes`,
and logs in as `ansible`. Answers go in `/root/lab-answers/<task>`, which
the lab creates; write them as root.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers with their own users and packages, reached over
SSH by name. On each, the user `ansible` accepts greg's key and may use
sudo without a password. For a root shell on a node,
`sudo podman exec -it node1 bash`.

## Tasks

1. As greg, find which `ansible.cfg` Ansible uses in your project directory
   and in `/tmp`. Write the two paths to `/root/lab-answers/1`, the
   project directory's on line 1 and `/tmp`'s on line 2.
2. List the settings your project's `ansible.cfg` changes, each with your
   file's path, and write the list to `/root/lab-answers/2`.
3. Create a role `motd` in `/home/greg/ansible/roles/motd` that writes
   `/etc/motd` from a default variable, `motd_text`, and use it on every
   node with the playbook `/home/greg/ansible/motd.yml`.
   `ansible all -a 'cat /etc/motd'` prints the text, and running the
   playbook with `-e motd_text=Hello` changes it. Leave `/etc/motd` with
   the default text.

## Hints

- `ansible --version | grep 'config file'`.
- `ansible-config dump --only-changed`; root can run it from greg's
  project with `cd /home/greg/ansible && ... >/root/lab-answers/2`.
- `ansible-galaxy role init roles/motd`; the task goes in `tasks/main.yml`
  and the variable in `defaults/main.yml`.
- A play with `hosts: all`, `become: true` and `roles: [motd]`.
