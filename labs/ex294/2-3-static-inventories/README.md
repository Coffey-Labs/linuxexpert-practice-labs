# EX294 2.3: Static inventories and groups

Write an inventory in INI and in YAML, with a group of groups and a group
variable, and add the control node so its tasks run locally.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) with an SSH key, and installs `ansible-core`. Work as greg,
in `/home/greg/ansible`: its `ansible.cfg` reads the inventory
`./inventory`, which doesn't exist yet, and logs in as `devops`.

The managed nodes `node1` (10.99.1.11), `node2` (10.99.1.12) and `node3`
(10.99.1.13) are AlmaLinux 10 containers reached over SSH by name. On
each, `devops` accepts greg's key. For a root shell on a node,
`sudo podman exec -it node1 bash`.

## Tasks

1. Write `/home/greg/ansible/inventory` in INI format, with node1 in group
   `dev`, node2 in `test`, node3 in `prod`, and a group `webservers` that
   contains the group `prod`. `ansible-inventory --graph` shows node3 under
   both `prod` and `webservers`, and `ansible webservers --list-hosts`
   lists node3.
2. Write the same inventory in YAML as `/home/greg/ansible/inventory.yml`,
   with a variable set on the `dev` group.
   `ansible-inventory -i inventory.yml --graph --vars` shows the same tree,
   with the variable on node1.
3. Add the control node to `/home/greg/ansible/inventory` as `control`, so
   tasks for it run locally: `ansible control -a hostname` prints this
   VM's name without SSH.

## Hints

- `[group:children]` lists groups; `[group:vars]` sets variables.
- In YAML, `hosts:` and `children:` map names to their contents, even when
  empty: `node1:` with a trailing colon. Group variables go under `vars:`.
- `ansible-inventory -y --list` prints an INI inventory as YAML.
- `ansible_connection=local` on the host's line.
- `ansible all -m ping` checks every node answers.
