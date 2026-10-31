# EX294 4.2: Finding modules with ansible-navigator

Browse the collections in an execution environment, use a module from its
documentation, and see a module that only the image has.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) with an SSH key, and installs `ansible-core` and
`ansible-navigator` (from PyPI, in `/opt/le-lab-navigator`). Work as
greg, in `/home/greg/ansible`: its `ansible.cfg` reads the inventory
`inventory`, logs in as `devops` and becomes root, and its
`ansible-navigator.yml` uses the execution environment image
`localhost/lab-ee:2.16` in stdout mode. The image is built on this VM
from AlmaLinux 10's ansible-core with the `ansible.posix` and
`community.general` collections from Ansible Galaxy; the control node
itself has only ansible-core's own modules.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers reached over SSH by name; on both, `devops`
accepts greg's key and may use sudo without a password. For a root shell
on a node, `sudo podman exec -it node1 bash`.

The nodes have no disks of their own, so storage work goes to this VM:
the inventory group `storage` holds `control`, which is this VM reached
over SSH at 10.99.1.1 (inside the execution environment, `localhost` is
the container, not this VM). There too `devops` accepts greg's key and
may use sudo without a password. The VM has a spare disk, `/dev/loop41`.

## Tasks

1. List the collections in the execution environment and find the module
   that manages SELinux booleans. Write its full name to
   `/root/lab-answers/1` (as root).
2. Read `community.general.lvg`'s documentation from the image, and write
   a playbook in `/home/greg/ansible` with a task that creates the volume
   group `data` on `/dev/loop41` for the `storage` group. Run it with
   `ansible-navigator run`; `vgs` on this VM shows `data`.
3. Find a module that's in the image but not on the control node, and
   write `/home/greg/ansible/both.yml`, a playbook that uses it. Run it
   both ways: navigator succeeds, ansible-playbook fails with "couldn't
   resolve module/action".

## Hints

- `ansible-navigator collections -m interactive` browses them; in stdout
  mode it prints every plugin as YAML, so pipe it through `grep`.
  `ansible-navigator doc -l`, `ansible-navigator doc NAME`.
- Use modules by their full name, `namespace.collection.module`.
- `ansible-doc -l` lists what the control node has.
