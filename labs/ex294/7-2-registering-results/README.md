# EX294 7.2: Registering results

Save the output of commands with `register` and use it: print part of it,
write it to a file on each node, and print one line per item of a loop.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) with an SSH key, and installs `ansible-core`. Work as greg,
in `/home/greg/ansible`: its `ansible.cfg` reads the inventory `inventory`
(group `nodes`), logs in as `devops` and becomes root.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers reached over SSH by name. On each, `devops` has
greg's key and passwordless sudo. For a root shell on a node,
`sudo podman exec -it node1 bash`.

## Tasks

1. Write `/home/greg/ansible/df.yml`, which runs `df -h /` on every node,
   saves the output, and prints only its second line, using
   `stdout_lines[1]`. Every task reports `ok`, not `changed`.
2. Write the output of `hostnamectl` on each node to `/root/hostinfo.txt`
   on that node, with a playbook.
3. Write `/home/greg/ansible/enabled.yml`, which loops
   `systemctl is-enabled` over three services, registers the result, and
   prints each service with its result: one line per service, labeled
   with the service's name.

## Hints

- `register: rootfs` and `changed_when: false`; `debug` with
  `msg: "{{ rootfs.stdout_lines[1] }}"`.
- `ansible.builtin.copy` with `content: "{{ info.stdout }}\n"`.
- `systemctl is-enabled` exits non-zero for a disabled service:
  `failed_when: false`. Loop over `result.results`, and set
  `loop_control: label: "{{ item.item }}"`.
- `ansible all -b -a 'cat /root/hostinfo.txt'` checks task 2.
