# EX294 1.1: Inventories, modules and ad hoc commands

Write an inventory with two groups, reach every host with the ping module,
install a package with an ad hoc command, and pick hosts with a pattern.

## Before you start

This VM is the control node. The lab installs `ansible-core` and creates
the user `greg` (password `Lab-Pass-1`), who has an SSH key. Work as greg
(`su - greg` as root), in `/home/greg/ansible`: its `ansible.cfg` reads the
inventory file `inventory`, which doesn't exist yet, and logs in as
`ansible`. Answers go in `/root/lab-answers/<task>`, which the lab creates;
write them as root.

The managed nodes `node1`, `node2` and `node3` (10.99.1.11 to .13) are
AlmaLinux 10 containers with their own users and packages, reached over
SSH by name. On each, the user `ansible` accepts greg's key and may use
sudo without a password. For a root shell on a node,
`sudo podman exec -it node1 bash`.

## Tasks

1. Write the inventory `/home/greg/ansible/inventory` with `node1` and
   `node2` in the group `webservers` and `node3` in `dbservers`, and show it
   as a tree.
2. Run the ping module against every host; each must answer `pong`.
3. Install the `tree` package on the webservers with an ad hoc command, then
   run the same command again: the first run says CHANGED, the second
   SUCCESS. `ansible webservers -a 'rpm -q tree'` finds it.
4. List the hosts matched by `all:!dbservers` without running anything, and
   write the hosts it shows to `/root/lab-answers/4`.

## Hints

- `ansible-inventory -i inventory --graph`.
- `ansible all -m ansible.builtin.ping`.
- `ansible webservers -m ansible.builtin.dnf -a 'name=tree state=present'`
  needs `-b` to become root.
- `--list-hosts`; quote the pattern so the shell leaves the `!` alone.
  Root can run Ansible from greg's project too:
  `cd /home/greg/ansible && ansible ... >/root/lab-answers/4`.
