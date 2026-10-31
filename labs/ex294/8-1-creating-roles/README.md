# EX294 8.1: Creating roles

Write a role that sets up a web server, give it a default that one host
overrides, and include it only on hosts with enough memory.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) and installs `ansible-core`. Work as greg, in
`/home/greg/ansible`: its `ansible.cfg` reads the inventory `inventory`,
logs in to the nodes as `devops` with greg's SSH key, and becomes root.

The managed nodes `node1` (10.99.1.11), `node2` (10.99.1.12) and `node3`
(10.99.1.13) are AlmaLinux 10 containers in the group `webservers`, with
no web server and no firewall yet. Containers share the VM's memory, so
the lab gives each its own as Ansible's facts see it: node1 and node2
have 4096 MiB, node3 has 1024 MiB. For a root shell on a node,
`sudo podman exec -it node1 bash`.

## Tasks

1. Create a role `apache` in `/home/greg/ansible/roles/apache` that
   installs httpd, starts and enables it, installs, starts and enables
   firewalld and opens the web port, and deploys a home page from a
   template showing the host's FQDN and IP address. Use it from a
   playbook on the web servers. `curl http://node1/` and
   `curl http://node2/` each show their own name and address (once task 2
   moves node2 to port 8080, its page is at `http://node2:8080/`).
2. Give the role a default port of 80 in `defaults/main.yml`, and
   override it for node2 with 8080. node2 then answers on port 8080; node1
   still uses 80 only.
3. Make the playbook include the role only on hosts with at least 2 GiB
   of memory, with `include_role` and a `when`, so node3 is skipped. If an
   earlier run put httpd on node3, remove it there.

## Hints

- `ansible-galaxy role init roles/apache` makes the layout.
- `ansible_facts['fqdn']` and `ansible_facts['default_ipv4']['address']`
  in `templates/index.html.j2`.
- httpd already listens on 80; a template in `/etc/httpd/conf.d/` can add
  `Listen {{ apache_port }}` when the port isn't 80, with a handler to
  restart httpd.
- `ansible.posix.firewalld` needs `ansible-galaxy collection install
  ansible.posix`; `permanent: true` and `immediate: true`.
- `host_vars/node2.yml` overrides a role default for one host.
- `ansible.builtin.include_role` is a task, so it takes `when`.
