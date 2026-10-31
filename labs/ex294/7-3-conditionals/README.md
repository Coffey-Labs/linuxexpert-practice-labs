# EX294 7.3: Conditionals

Make tasks run only where they apply: on hosts that have a disk, on hosts
in a group with enough memory, and when an extra variable asks for it.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) and installs `ansible-core`. Work as greg, in
`/home/greg/ansible`: its `ansible.cfg` reads the inventory `inventory`,
logs in to the nodes as `devops` with greg's SSH key, and becomes root.

The managed nodes `node1` (10.99.1.11), `node2` (10.99.1.12) and `node3`
(10.99.1.13) are AlmaLinux 10 containers. node1 is in the group
`webservers`, node2 and node3 in `dbservers`. Containers share the VM's
memory and disks, so the lab gives each node its own memory size and
disks, as Ansible's facts see them: look with
`ansible all -m setup -a 'filter=ansible_memtotal_mb'` and
`filter=ansible_devices`. For a root shell on a node,
`sudo podman exec -it node1 bash`.

## Tasks

1. Write `/home/greg/ansible/disk.yml`, which prints a message of your
   choice on hosts that have a disk `vdc`, and the message
   `Disk vdc does not exist` on the others. Each host prints exactly one
   of the two.
2. Write `/home/greg/ansible/mariadb.yml`, with one play that targets
   `all`, to install `mariadb-server` only on hosts in the `dbservers`
   group with at least 2 GiB of memory. Run it; the task is skipped on the
   web servers.
3. Write `/home/greg/ansible/upgrade.yml` with a task that prints
   `Upgrading` and runs only when `-e upgrade=true` is given. It's skipped
   with `-e upgrade=false` and without `-e`.

## Hints

- `'vdc' in ansible_facts['devices']`; a `when` needs no braces.
- `'dbservers' in group_names`, `ansible_facts['memtotal_mb'] >= 2048`; a
  list under `when` means all of them.
- Extra vars are strings: `upgrade | default(false) | bool`.
- Run with `-v` to see `false_condition` on skipped hosts.
