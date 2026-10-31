# EX294 9.8: Users and groups

Create users from a variables file on the right hosts, in the right
groups and with hashed passwords, keep the playbook idempotent, and give a
group sudo rights.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) with an SSH key, and installs `ansible-core`. Work as greg,
in `/home/greg/ansible`: its `ansible.cfg` reads the inventory `inventory`,
logs in as `devops` and becomes root. `node1` is in the group
`webservers` and `node2` in `dbservers`. `user_list.yml` there is the
variables file:

```yaml
users:
  - name: fred
    job: developer
    uid: 3001
  - name: wilma
    job: manager
    uid: 3002
  - name: barney
    job: developer
    uid: 3003
```

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers, prepared as in chapter 3.1: `devops` takes greg's
key and may use sudo without a password, from `/etc/sudoers.d/devops`.
For a root shell on a node, `sudo podman exec -it node1 bash`.

## Tasks

1. Write `/home/greg/ansible/users.yml` to create the users from
   `user_list.yml`, with their UIDs: developers on the web servers in the
   group `developers`, managers on the database servers in `opsmgr`, all
   with the password `Redhat123`, hashed. `id` shows the groups, and `ssh
   fred@node1` with the password works.
2. Make `users.yml` report `changed=0` on a second run.
3. Let the `developers` group run any command with sudo without a
   password, with a validated drop-in. `sudo -n whoami` as a developer on node1
   prints `root`.

## Hints

- `vars_files`, a `loop` over `users` and `when: item.job == 'developer'`;
  `ansible.builtin.group` before `ansible.builtin.user` with `groups` and
  `append: true`.
- `password_hash('sha512')` makes the hash; `update_password: on_create`
  or a fixed salt keeps a second run from changing it.
- `ansible.builtin.copy` with `validate: /usr/sbin/visudo -cf %s`, to a
  file of its own (not `/etc/sudoers.d/devops`, which Ansible's own login
  needs).
- Test a login with `ssh -o PubkeyAuthentication=no fred@node1`.
