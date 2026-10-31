# EX294 8.3: Installing collections

Install collections into your project: one from a tarball on a web
server, one from Galaxy at a version your ansible-core supports, and one
into a directory Ansible doesn't look in.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) and installs `ansible-core`. Work as greg, in
`/home/greg/ansible`: its `ansible.cfg` reads the inventory `inventory`,
logs in to the node as `devops` with greg's SSH key, and becomes root.
It doesn't set `collections_path` yet.

The managed node `node1` (10.99.1.11) is an AlmaLinux 10 container
running httpd, serving `/var/www/html`. For a root shell there,
`sudo podman exec -it node1 bash`. The collections come from Ansible
Galaxy, so the VM needs internet access.

## Tasks

1. Download `ansible.posix` from Galaxy as a tarball, serve it from node1
   under `http://node1/collections/`, and install it into
   `/home/greg/ansible/collections` from a requirements file with
   `type: url`. `ansible-galaxy collection list` shows it under the
   project's `collections` directory.
2. Install `community.general` at a version that works with your
   ansible-core, and write `/home/greg/ansible/ini.yml`, which uses its
   `ini_file` module to set `port = 8080` in the section `[web]` of
   `/etc/lab.ini` on node1. `ansible-doc community.general.ini_file`
   works without a warning, and the playbook runs.
3. Install `community.crypto` with `-p /home/greg/elsewhere`, a directory
   that isn't in `collections_path`. ansible-galaxy warns, and Ansible
   can't find its modules: `ansible-doc
   community.crypto.openssl_privatekey` finds nothing.

## Hints

- `ansible-galaxy collection download ansible.posix -p DIR`, then
  `ansible node1 -m copy` to put it under `/var/www/html/collections/`.
- A collections requirements file starts with `collections:`; a tarball
  entry is `- name: URL` with `type: url`.
- `collections_path = ./collections:/usr/share/ansible/collections` in
  `ansible.cfg`, then `ansible-galaxy collection install -r FILE -p
  collections`.
- `ansible --version` shows your ansible-core; a collection's
  `meta/runtime.yml` has `requires_ansible`. Galaxy doesn't check it, so
  pin a version: `version: "<12"`.
