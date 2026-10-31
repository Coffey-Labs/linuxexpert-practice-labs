# EX294 5.1: Cloning a repository

Make a bare Git repository on a managed node, clone it on the control node
over SSH, set your Git identity and push a first commit, and clone it a
second time.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) with an SSH key, and installs `ansible-core` and `git`. Work
as greg. His Ansible project is `/home/greg/ansible`: its `ansible.cfg`
reads the inventory `inventory`, logs in as `devops` and becomes root.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers reached over SSH by name, with `git` installed. On
each, `devops` has greg's key and passwordless sudo, so
`ssh devops@node1` works without a password. For a root shell on a node,
`sudo podman exec -it node1 bash`. Everything stays on this VM: the
repository lives on a node, not on a hosting service.

## Tasks

1. Make a bare repository `/srv/git/playbooks.git` with the branch `main`
   on `node1` (`git init --bare -b main /srv/git/playbooks.git`, with
   Ansible or in a shell there). Then, as greg, set `init.defaultBranch`
   to `main` and clone it over SSH into `/home/greg/playbooks`, so that
   `git remote -v` there shows the URL for fetch and push, and
   `git status` says "On branch main".
2. Set greg's Git name and email globally, then commit a `README.md` in
   the clone and push it, so that `git log` shows them as the author.
3. Clone the same repository again, into a directory of your choosing in
   greg's home, so that it has the same `git log --oneline` as the first
   clone.

## Hints

- `ansible node1 -a 'git init --bare -b main /srv/git/playbooks.git'`
  makes it as root; for `devops` to push to it, give it to devops with
  `ansible.builtin.file` and `recurse: true`.
- `git clone devops@node1:/srv/git/playbooks.git`; the first SSH
  connection asks you to trust node1's host key.
- An empty repository clones with a warning. Over SSH, its clone starts
  on Git's own default branch, `master`, unless
  `git config --global init.defaultBranch main` comes first; in a clone
  that's already on `master`, `git switch -c main` before the first
  commit.
- The first push of a new branch: `git push -u origin main`.
- `git config --global user.name ...`, `user.email`, `--list`;
  `git log --format='%an <%ae>'` shows the author.
