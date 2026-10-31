# EX294 9.2: Services

Start, enable, stop and mask services, deploy a unit of your own, and set
a default target, all so that a second run changes nothing.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`, sudo without a password) with an SSH key, and installs
`ansible-core`. Work as greg, in `/home/greg/ansible`: its `ansible.cfg`
reads the inventory `inventory`, logs in as `devops` and becomes root.
`node1` is in the group `webservers`, `node2` in `dbservers`, and this VM
itself in `control`, as `localhost ansible_connection=local`.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers, prepared as in chapter 3.1: `devops` takes greg's
key and may use sudo without a password. `rpcbind` runs on both. They
share this VM's clock, so `chronyd` can be enabled there but never runs
(systemd skips it); it runs here, on the control node, where the lab has
stopped and disabled it. For a root shell on a node, `sudo podman exec -it
node1 bash`.

## Tasks

1. Make sure `chronyd` is running and enabled on the control node and
   enabled on node1 and node2, and `rpcbind` stopped and masked on the
   nodes. `systemctl is-enabled chronyd rpcbind` on a node shows `enabled`
   and `masked`, also after a reboot.
2. Write `/home/greg/ansible/hello.yml` to deploy a oneshot unit
   `hello.service` on every node that writes `hello from systemd` to the
   journal, and enable and start it. `journalctl` shows the line, and a
   second run reports `changed=0`.
3. Write `/home/greg/ansible/target.yml` to set the default target of the
   database server to `multi-user.target`. `systemctl get-default`
   agrees, and the task is `ok` on a second run.

## Hints

- `ansible.builtin.service` with `state: started` and `enabled: true`;
  `ansible.builtin.systemd_service` with `masked: true`. Install `chrony`
  on the nodes first. On the nodes, `state: started` for chronyd reports
  `changed` every time, because systemd skips it there.
- A oneshot unit that should count as started needs `RemainAfterExit=yes`,
  and `daemon_reload: true` before it starts.
- `systemctl get-default` in a `command` task with `changed_when: false`,
  or `ansible.builtin.file` with `state: link` on
  `/etc/systemd/system/default.target`.
- Check with `ansible all -a 'systemctl is-enabled chronyd rpcbind'`.
