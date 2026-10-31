# EX294 1.3: Plays and playbooks

Write a playbook with two plays, preview a change with check mode, and
find a YAML mistake with a syntax check.

## Before you start

This VM is the control node. The lab installs `ansible-core` and creates
the user `greg` (password `Lab-Pass-1`), who has an SSH key. Work as greg
(`su - greg` as root), in `/home/greg/ansible`: its `ansible.cfg` reads the
inventory `inventory`, which has `node1` in the group `webservers` and
`node2` in `dbservers`, and logs in as `ansible`. Answers go in
`/root/lab-answers/<task>`, which the lab creates; write them as root.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers with their own users and packages, reached over
SSH by name. On each, the user `ansible` accepts greg's key and may use
sudo without a password. They run no firewall. For a root shell on a node,
`sudo podman exec -it node1 bash`.

## Tasks

1. Write `/home/greg/ansible/site.yml` with one play that installs, starts
   and enables httpd and writes a home page,
   `/var/www/html/index.html`, on the webservers, and another play that
   installs `mariadb-server` on the dbservers. Run it twice: the second run
   shows `changed=0` for every host, and `curl http://node1` from the
   control node prints the page (open the firewall if one is running).
2. Change the page's text in `site.yml` and preview the change on node1
   only, without making it: `--check --diff --limit node1` shows the old and
   the new line, and `curl http://node1` still prints the old text. Leave
   it that way.
3. Copy `site.yml` to `/home/greg/ansible/broken.yml`, break the
   indentation of one task there, and find the error with `--syntax-check`.
   Write the line number it names to `/root/lab-answers/3`.

## Hints

- The plays are a YAML list: each starts with `- name:` and has `hosts:`,
  `become: true` and `tasks:`.
- `ansible.builtin.dnf`, `ansible.builtin.copy` with `content:` and
  `dest:`, and `ansible.builtin.service` with `state: started` and
  `enabled: true`.
- `ansible-playbook site.yml --check --diff --limit node1`.
- `ansible-playbook broken.yml --syntax-check`; look for "line N" in the
  error.
