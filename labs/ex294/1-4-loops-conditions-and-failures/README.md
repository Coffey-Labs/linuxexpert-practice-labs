# EX294 1.4: Loops, conditions and task failure

Create users from a list of dictionaries, run tasks only where a condition
holds, loop over a dictionary, and watch one host fail while the others
carry on.

## Before you start

This VM is the control node. The lab installs `ansible-core` and creates
the user `greg` (password `Lab-Pass-1`), who has an SSH key. Work as greg
(`su - greg` as root), in `/home/greg/ansible`: its `ansible.cfg` reads the
inventory `inventory`, which has `node1` and `node2` in the group `nodes`,
and logs in as `ansible`.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers with their own users and packages, reached over
SSH by name. On each, the user `ansible` accepts greg's key and may use
sudo without a password. For a root shell on a node,
`sudo podman exec -it node1 bash`.

## Tasks

1. Write `/home/greg/ansible/users.yml`, which creates the users alice (in
   the group wheel) and bob on node1 from a list of dictionaries, in one
   task. `ansible node1 -a 'id alice'` shows wheel, and a second run shows
   both items `ok`.
2. Write `/home/greg/ansible/memory.yml`, which prints one message only on
   hosts with more than 2 GiB of memory and another only on the rest. Each
   host shows one `ok` and one `skipping`.
3. Write `/home/greg/ansible/services.yml`, which loops over a dictionary of
   service names and ports with `dict2items` and prints each pair: one line
   per key, showing `item.key` and `item.value`.
4. Write `/home/greg/ansible/fail.yml`, in which a task fails on one host
   while the others carry on to the next task. The recap shows `failed=1`
   for that host only.

## Hints

- `loop: "{{ users }}"` over a list in `vars:`, with
  `name: "{{ item.name }}"` and `groups: "{{ item.groups }}"`.
- `when: ansible_facts['memtotal_mb'] > 2048`, and `<= 2048` for the other
  task. All the hosts here have the same memory, so they all print the
  same message.
- `loop: "{{ ports | dict2items }}"` with
  `msg: "{{ item.key }} {{ item.value }}"`.
- `ansible.builtin.command: /bin/false` with
  `when: inventory_hostname == 'node1'`, then any task after it. Don't use
  `ignore_errors`.
