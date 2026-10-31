# EX294 1.2: Variables and facts

Give a group and one host their own value of a variable, print facts from
a playbook, and add a custom fact to a node.

## Before you start

This VM is the control node. The lab installs `ansible-core` and creates
the user `greg` (password `Lab-Pass-1`), who has an SSH key. Work as greg
(`su - greg` as root), in `/home/greg/ansible`: its `ansible.cfg` reads the
inventory `inventory`, which has `node1` and `node2` in the group
`webservers`, and logs in as `ansible`. There are no variable files yet.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers with their own users and packages, reached over
SSH by name. On each, the user `ansible` accepts greg's key and may use
sudo without a password. For a root shell on a node,
`sudo podman exec -it node1 bash`.

## Tasks

1. Set `http_port` to 80 for the webservers group and to 8080 for node2
   alone, and print it from a playbook, `/home/greg/ansible/port.yml`, that
   runs on the webservers. node1 prints 80 and node2 8080; with
   `-e http_port=9000` both print 9000.
2. Write `/home/greg/ansible/facts.yml`, which prints each managed node's
   distribution, its version and its memory in MiB from facts. Each host's
   numbers match `ansible HOST -m setup -a 'filter=ansible_memtotal_mb'`
   (and `ansible_distribution*`).
3. Write a custom fact on node1 in `/etc/ansible/facts.d/role.fact`, with
   the section `[general]` and `role=web`.
   `ansible node1 -m setup -a 'filter=ansible_local'` shows `"role": "web"`
   under `general`.

## Hints

- `group_vars/webservers.yml` and `host_vars/node2.yml` next to the
  inventory; `ansible-inventory --host node2` shows what a host gets.
- `ansible.builtin.debug` with `msg: "{{ http_port }}"` or `var: http_port`.
- `ansible_facts['distribution']`, `['distribution_version']` and
  `['memtotal_mb']`.
- The fact file is plain INI and must not be executable (an executable
  `.fact` is run as a program). Write it with `ansible.builtin.copy` and
  `become: true`, or by hand on the node.
