# EX294 4.3: Navigator inventories and settings

Make ansible-navigator see the same inventory and `ansible.cfg` as
Ansible does, and give its execution environment a roles directory from
outside the project.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) with an SSH key, and installs `ansible-core` and
`ansible-navigator` (from PyPI, in `/opt/le-lab-navigator`). Work as
greg, in `/home/greg/ansible`: its `ansible.cfg` reads the inventory
`inventory`, logs in as `devops` and becomes root. Its
`ansible-navigator.yml` uses the execution environment image
`localhost/lab-ee:2.16` (built on this VM from AlmaLinux 10's ansible-core
and collections from Ansible Galaxy; no registry or login) in stdout mode,
but someone left two more settings in it.

greg also has a role, `banner`, in `/home/greg/roles`, outside the
project, and the project's `banner.yml` applies it to every node.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers reached over SSH by name; on both, `devops`
accepts greg's key and may use sudo without a password. For a root shell
on a node, `sudo podman exec -it node1 bash`.

## Tasks

1. Show the inventory's groups with ansible-navigator, in stdout mode and
   in the interactive browser, and make them match: `ansible-navigator
   inventory -m stdout --graph` prints the same as `ansible-inventory
   --graph`.
2. Find which `ansible.cfg` ansible-navigator uses, and make it the
   project's: `ansible-navigator config dump --only-changed -m stdout`
   shows `CONFIG_FILE() = /home/greg/ansible/ansible.cfg`.
3. Set `roles_path` in the project's `ansible.cfg` to `/home/greg/roles`
   and run `banner.yml` with navigator: it fails with "the role 'banner'
   was not found". Fix it with a volume mount in `ansible-navigator.yml`,
   so the run succeeds and every node has `/etc/motd.d/banner`.

## Hints

- `ansible-navigator settings --effective --sources -m stdout` says where
  each setting came from: look at `ansible.config.path` and
  `ansible.inventory.entries`.
- `ansible-navigator inventory -m interactive`: numbers open a view, Esc
  goes back, `:q` quits.
- `execution-environment: volume-mounts:` takes a list of `src`, `dest`
  and `options` (`Z` relabels the directory for SELinux).
