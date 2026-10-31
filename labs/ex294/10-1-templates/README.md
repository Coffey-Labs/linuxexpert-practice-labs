# EX294 10.1: Templates

Generate files from Jinja2 templates: a hosts file built from every
node's facts, a hardware report with each host's own values, and a
configuration file checked with `validate` before it's installed.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) and installs `ansible-core`. Work as greg, in
`/home/greg/ansible`: its `ansible.cfg` reads the inventory `inventory`,
logs in to the nodes as `devops` with greg's SSH key, and becomes root.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are in
the group `webservers`, `node3` (10.99.1.13) in `dbservers`; all three
are AlmaLinux 10 containers. Containers share the VM's memory and disks,
so the lab gives each node its own memory size and disks, as Ansible's
facts see them: they differ from node to node. For a root shell on a
node, `sudo podman exec -it node1 bash`.

## Tasks

1. Generate `/etc/myhosts` on the database servers from a template that
   lists every managed node, one line each, as
   `ADDRESS FQDN SHORT-NAME`, for example
   `10.99.1.11 node1.lab.example node1`. The web servers get no
   `/etc/myhosts`.
2. Write a hardware report template and deploy it to `/root/hwreport.txt`
   on every node, with each node's own values, in this form:

       HOST=node1
       MEMORY=<memory in MiB>
       BIOS=<BIOS version>
       DISK_SIZE_VDB=<size of disk vdb>
       DISK_SIZE_VDD=<size of disk vdd>

   A missing disk shows as `NONE`.
3. Write `/home/greg/ansible/sshd.yml`, which templates the sshd drop-in
   `/etc/ssh/sshd_config.d/50-lab.conf` on all nodes with the line
   `PermitRootLogin {{ sshd_root_login }}` (the variable is `no` by
   default) and checks it with `validate` before installing it. Then try
   `-e sshd_root_login=maybe`: the task fails with "failed to validate",
   and the old file is unchanged.

## Hints

- `hostvars[host]['ansible_facts']` has another host's facts, but only
  if the play gathered them: target `all` and limit the task with `when`.
- `ansible_facts['default_ipv4']['address']`, `['fqdn']`, `['hostname']`.
- `ansible_facts['memtotal_mb']`, `['bios_version']`, and
  `ansible_facts['devices']['vdb']['size'] | default('NONE')`.
- `validate: /usr/sbin/sshd -t -f %s`.
