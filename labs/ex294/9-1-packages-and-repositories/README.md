# EX294 9.1: Packages and repositories

Give the managed nodes their repositories, install packages and a group on
the right hosts, and bring the web servers up to date.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) with an SSH key, and installs `ansible-core`. Work as greg,
in `/home/greg/ansible`: its `ansible.cfg` reads the inventory `inventory`,
logs in as `devops` and becomes root. `node1` is in the group `webservers`
and `node2` in `dbservers`.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers, prepared as in chapter 3.1: `devops` takes greg's
key and may use sudo without a password, so `ansible all -m ping` works
straight away. The lab has taken away every repository on both nodes
(the old files are in `/root/repos.orig`), and left one package on node1
a version behind. For a root shell on a node, `sudo podman exec -it node1
bash`.

## Tasks

1. Configure BaseOS and AppStream repositories on every node, with
   signature checking, from URLs you choose (the AlmaLinux 10 mirrors at
   `https://repo.almalinux.org/almalinux/10/`, for example). `dnf
   repolist` on each node lists both, and `dnf install` works.
2. In one playbook, install a package group on the database servers, and
   `php` and `mariadb` on the web servers.
3. Upgrade every package on the web servers, so `dnf check-update` there
   finds nothing to update.

## Hints

- `ansible.builtin.yum_repository` with `baseurl`, `gpgcheck: true` and
  `gpgkey`; `ansible.builtin.rpm_key` imports the key. The key is at
  `https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux-10`.
  `rpm_key` needs `gpg2`; the lab installed `gnupg2` on the nodes before
  it took their repositories away.
- A group is `name: "@Group Name"` in `ansible.builtin.dnf`; `dnf group
  list --hidden` on a node shows the names. A group of only optional
  packages installs nothing.
- `name: "*"` with `state: latest` updates everything.
- Check with `ansible all -a 'dnf repolist'` and `ansible webservers -a
  'rpm -q php mariadb'`.
