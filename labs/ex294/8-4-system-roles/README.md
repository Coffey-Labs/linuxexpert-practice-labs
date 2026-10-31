# EX294 8.4: System roles

Use the RHEL system roles for time synchronization and SELinux, and find
a role's variables in its documentation.

## Before you start

Time and SELinux belong to the kernel, which the lab's container nodes
share with the VM, so this lab has no managed nodes: the control node
manages itself. The lab creates the user `greg` (password `Lab-Pass-1`,
allowed to use sudo) and installs `ansible-core` and `rhel-system-roles`,
which AlmaLinux ships in AppStream as the collection
`redhat.rhel_system_roles`. Work as greg, in `/home/greg/ansible`: its
`ansible.cfg` reads the inventory `inventory`, where the control node is
`localhost` (with `ansible_connection=local`) in the group `webservers`,
and becomes root.

The lab sets SELinux to permissive, now and in `/etc/selinux/config`, and
turns `httpd_can_network_connect` off. Reset puts both back, and
`/etc/chrony.conf` too. The VM needs internet access to reach an NTP
pool.

## Tasks

1. Write `/home/greg/ansible/timesync.yml`, which configures time
   synchronization on every host with the timesync system role, using a
   pool your hosts can reach, such as `pool.ntp.org`. `chronyc sources`
   lists servers from the pool, and a second run changes nothing.
2. Write `/home/greg/ansible/selinux.yml`, which uses the selinux system
   role to set SELinux to enforcing on all hosts, and turn on
   `httpd_can_network_connect` persistently on the web servers.
   `getenforce` and `getsebool httpd_can_network_connect` show it, also
   after a reboot.
3. Find which variable the storage role uses for a logical volume's size,
   and write its name to `/root/lab-answers/3`.

## Hints

- `/usr/share/doc/rhel-system-roles/ROLE/` has each role's `README.md`
  and example playbooks.
- The roles are `redhat.rhel_system_roles.timesync` and
  `redhat.rhel_system_roles.selinux`.
- `timesync_ntp_servers` with `pool: true`; `selinux_state` and
  `selinux_booleans` with `persistent: true`.
- In the storage README, look under `storage_pools` for its `volumes`.
