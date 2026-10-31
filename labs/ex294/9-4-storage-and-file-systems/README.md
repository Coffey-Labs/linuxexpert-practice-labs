# EX294 9.4: Storage and file systems

Partition a disk, make file systems and mount them for good, size a
logical volume to what each host has room for, and let the storage system
role do the same from variables.

## Before you start

This VM is the control node, and here also the host with the disks:
`localhost ansible_connection=local`, in the inventory group `storage`.
The lab creates the user `greg` (password `Lab-Pass-1`, sudo without a
password) with an SSH key, and installs `ansible-core`. Work as greg, in
`/home/greg/ansible`: its `ansible.cfg` reads the inventory `inventory`,
logs in as `devops` and becomes root. The `ansible.posix` and
`community.general` collections and the system roles aren't installed
yet.

Spare disks on this VM, where the chapter has `vdb` and friends:

- `/dev/loop40`, 2 GiB, for task 1
- `/dev/loop41`, 1 GiB, for task 2
- `/dev/loop42`, 2 GiB, for task 3

The managed node `node1` (10.99.1.11, group `nodes`) is an AlmaLinux 10
container, prepared as in chapter 3.1: `devops` takes greg's key and may
use sudo without a password. A container has no disks of its own, so it
plays the host without the volume group. For a root shell there, `sudo
podman exec -it node1 bash`.

## Tasks

1. On the storage hosts, create a 1 GiB partition on `/dev/loop40`, put
   XFS on it, and mount it at `/srv/archive` persistently. `findmnt
   /srv/archive` shows it, also after a reboot.
2. Create the volume group `research` on `/dev/loop41` on the storage
   hosts. Then write `/home/greg/ansible/lv.yml` for all hosts: a 1500 MiB
   logical volume `data` in `research` where it fits, an 800 MiB one with
   the message "Could not create logical volume of that size" where it
   doesn't, ext4 on it mounted at `/mnt/data`, and the message "Volume
   group does not exist" on hosts without `research`. Each host ends with
   the right size or message, and `lvs research` agrees.
3. Use the storage system role to make a 1 GiB XFS logical volume on
   `/dev/loop42`, mounted at `/srv/web`. Check with `lsblk` and
   `/etc/fstab`.

## Hints

- `ansible-galaxy collection install ansible.posix
  'community.general:>=11,<12'`: community.general 12 and later need a
  newer ansible-core than this one.
- `community.general.parted` (needs the `parted` package here),
  `community.general.filesystem`, `ansible.posix.mount` with `state:
  mounted`. A partition of `/dev/loop40` is `/dev/loop40p1`.
- `community.general.lvg` and `lvol`; `block` and `rescue` for the
  smaller volume; `ansible_facts['lvm']['vgs']` says which hosts have
  `research`.
- The system roles come from the `rhel-system-roles` package; in
  `storage_pools`, a disk is named like `loop42`.
