# EX294 7.1: Commonly used modules

Set up a web server with the core modules, make a `command` task run only
once, and read a package's version from the package facts.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) with an SSH key, and installs `ansible-core`. Work as greg,
in `/home/greg/ansible`: its `ansible.cfg` reads the inventory `inventory`
(group `nodes`), logs in as `devops` and becomes root. No collections are
installed beyond ansible-core's own.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers reached over SSH by name. On each, `devops` has
greg's key and passwordless sudo. node1 runs firewalld, which lets in only
SSH. For a root shell on a node, `sudo podman exec -it node1 bash`.

## Tasks

1. Write `/home/greg/ansible/web.yml`, which installs, starts and enables
   httpd on `node1`, deploys its home page `/var/www/html/index.html`, and
   opens node1's firewall for it (firewalld keeps running). Then
   `curl http://node1/` on the control node prints the page, and a second
   run of `web.yml` reports `changed=0`.
2. Write `/home/greg/ansible/dd.yml`, whose `command` task creates
   `/root/swapfile` (16 MiB of zeros) on every node with `dd`, and make it
   run only once: a second run of `dd.yml` reports `ok` for it, not
   `changed`.
3. Write `/home/greg/ansible/sshver.yml`, which prints the installed
   version of `openssh-server` on every node without running `rpm`.

## Hints

- `ansible.builtin.dnf`, `copy`, `service`; `ansible.posix.firewalld`
  needs `ansible-galaxy collection install ansible.posix`, with
  `permanent: true` and `immediate: true`.
- `creates:` makes a command skip once its file exists.
- `ansible.builtin.package_facts`, then `debug` with
  `ansible_facts['packages']['openssh-server'][0]['version']`.
