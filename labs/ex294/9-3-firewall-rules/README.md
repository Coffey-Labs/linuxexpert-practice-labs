# EX294 9.3: Firewall rules

Open services and ports on the managed nodes with
`ansible.posix.firewalld`, see the difference between permanent and
immediate, and do the same with the firewall system role.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) with an SSH key, and installs `ansible-core`. Work as greg,
in `/home/greg/ansible`: its `ansible.cfg` reads the inventory `inventory`,
logs in as `devops` and becomes root. `node1` is in the group `webservers`
and `node2` in `dbservers`. The `ansible.posix` collection and the system
roles aren't installed yet.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers, prepared as in chapter 3.1: `devops` takes greg's
key and may use sudo without a password. Both run firewalld, and node1
runs a web server that the firewall blocks for now. For a root shell on a
node, `sudo podman exec -it node1 bash`.

## Tasks

1. Open HTTP and port 8080/tcp permanently and immediately on the web
   servers. `curl http://node1/` works from this VM, and `firewall-cmd
   --permanent --list-all` on node1 lists both.
2. Add port 9090/tcp on the web servers with `permanent: true` only, and
   find it: `--list-ports` doesn't show it, `--permanent --list-ports`
   does. Then reload firewalld there, after which both do.
3. Use the firewall system role to allow `mysql` on the database servers.
   `firewall-cmd --list-services` on node2 includes `mysql`.

## Hints

- `ansible-galaxy collection install ansible.posix` for
  `ansible.posix.firewalld`: `service` or `port`, `permanent`,
  `immediate`, `state: enabled`.
- `ansible webservers -a 'firewall-cmd --reload'`, or a
  `systemd_service` task with `state: reloaded`.
- The system roles come from the `rhel-system-roles` package on the
  control node; the role is `redhat.rhel_system_roles.firewall`, with the
  rules in the variable `firewall`. Its README is in
  `/usr/share/doc/rhel-system-roles/firewall/`.
