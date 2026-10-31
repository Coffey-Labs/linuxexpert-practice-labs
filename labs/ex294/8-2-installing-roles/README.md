# EX294 8.2: Installing roles

Install roles written elsewhere: tarballs from a web server and a role
from a Git branch, all from a requirements file, then update one.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) and installs `ansible-core` and `git`. Work as greg, in
`/home/greg/ansible`: its `ansible.cfg` reads the inventory `inventory`,
logs in to the node as `devops` with greg's SSH key, and becomes root.

- The managed node `node1` (10.99.1.11) is an AlmaLinux 10 container
  running httpd, serving `/var/www/html`. For a root shell there,
  `sudo podman exec -it node1 bash`.
- `/home/greg/role-src` has two roles, `motd` and `issue`.
- `/srv/git/chrony-role.git` is a Git repository (owned by greg) with a
  role `chrony` on the branches `main` and `devel`.

## Tasks

1. Make a tarball of each role in `~/role-src`, serve them from node1 as
   `http://node1/roles/motd.tar.gz` and `http://node1/roles/issue.tar.gz`,
   and install both into `/home/greg/ansible/roles` with the requirements
   file `/home/greg/ansible/roles/requirements.yml`.
   `ansible-galaxy role list -p roles` lists them under the project's
   `roles` directory.
2. Install the role `chrony` from `/srv/git/chrony-role.git` at the branch
   `devel`. `ansible-galaxy role list -p roles` shows `devel` as its
   version.
3. Change the role in its source: clone the repository, commit a change
   on `devel`, and push it. Then update your installed copy. A plain
   install skips it; `--force` gets the new version.

## Hints

- A role tarball has the role's directory at its top:
  `tar -czf motd.tar.gz -C ~/role-src motd`.
- `ansible node1 -m copy -a "src=... dest=/var/www/html/roles/"` puts a
  file on the web server.
- In the requirements file, each role has `name` and `src`; a Git source
  is `git+file:///srv/git/chrony-role.git` with `version: devel`.
- `ansible-galaxy role install -r roles/requirements.yml -p roles`.
