# EX294 5.2: Adding and pushing files

Add a playbook to a clone and push it, ignore files that don't belong in
the repository, and get past a rejected push with a merge.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) with an SSH key and a Git name and email, and installs
`ansible-core` and `git`. Work as greg. His Ansible project is
`/home/greg/ansible`, with a playbook `site.yml`.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers reached over SSH by name. On node1, the bare
repository `/srv/git/playbooks.git` (owned by `devops`, who has greg's
key) has one commit, and greg's clone of it is `/home/greg/playbooks`,
with origin `devops@node1:/srv/git/playbooks.git`. For a root shell on a
node, `sudo podman exec -it node1 bash`. Everything stays on this VM: the
repository lives on a node, not on a hosting service.

## Tasks

1. Copy `/home/greg/ansible/site.yml` into `/home/greg/playbooks`, commit
   it and push it, so that a fresh clone in another directory contains
   it.
2. In `/home/greg/playbooks`, add a `.gitignore` that ignores
   ansible-navigator's playbook artifacts (`*-artifact-*.json`) and log
   (`ansible-navigator.log`) and the vault password file `.vault_pass`,
   and commit it. Then `git status --short` doesn't list such files.
3. Make a second clone of the repository, and push a commit from it. Then
   make a different commit in `/home/greg/playbooks` and try to push it:
   it's rejected. Pull with `git pull --no-rebase`, then push again, so
   that `git log --graph --oneline` shows the merge and node1's repository
   has it.

## Hints

- `git add`, `git commit -m`, `git push`; `git log origin/main --oneline`.
- `touch site-artifact-2026-10-30T10:00:00.json ansible-navigator.log
  .vault_pass` and `git status --short` test the `.gitignore`.
- Plain `git pull` on diverged branches stops with "Need to specify how
  to reconcile divergent branches"; `--no-rebase` merges, and
  `git config --global pull.rebase false` makes that the default.
