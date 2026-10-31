# EX294 6.1: VS Code with Git and ansible-navigator

Clone a project in VS Code, commit and push a playbook from the Source
Control view, and run playbooks from the Ansible extension's menu.

## Before you start

You need VS Code on your own computer with the Remote - SSH extension:
connect to this VM as greg (with his password, or add your key to his
`~/.ssh/authorized_keys`), and install Red Hat's Ansible extension
(`redhat.ansible`) on the remote side when VS Code offers it.

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) with an SSH key, and installs `ansible-core`, `git` and
`ansible-navigator` (from PyPI, in `/opt/le-lab-navigator`). greg's Git
repository is `/home/greg/git/ansible.git`, with one commit on `main`:
an `ansible.cfg` that reads `inventory`, logs in as `devops` and becomes
root, the inventory, and `site.yml`, which checks every node and adds a
line to the node's `/var/log/lab-runs.log` saying which command ran it
and the `--limit`. greg has no Git identity yet.

greg's podman has the execution environment image `localhost/lab-ee:2.16`
(built on this VM from AlmaLinux 10's ansible-core and collections from
Ansible Galaxy; no registry or login).

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers reached over SSH by name; on both, `devops`
accepts greg's key and may use sudo without a password. For a root shell
on a node, `sudo podman exec -it node1 bash`.

## Tasks

1. In VS Code, clone `/home/greg/git/ansible.git`, create a new playbook in
   the Ansible language mode with completion, and commit and push it from
   the Source Control view. `git log origin/main --oneline` in the
   terminal shows the commit, and a fresh clone has the file.
2. Turn on the extension's execution environment setting with the image
   `localhost/lab-ee:2.16`, and run a playbook from the right-click menu.
   Not graded: check that the terminal shows `ansible-navigator run ...
   --ee true --pae false --ce podman --eei localhost/lab-ee:2.16`.
3. Set `ansible.playbook.arguments` to `--limit node1` and run `site.yml`
   via ansible-playbook from the menu. Only node1 appears in the recap.

## Hints

- Command Palette: **Git: Clone** takes the path as the URL. If the
  commit fails for want of `user.name`, set it with `git config --global`
  in the terminal.
- The status bar shows the file's language mode; click **YAML** to
  choose **Ansible**.
- Settings: search for `ansible.executionEnvironment` and
  `ansible.playbook.arguments` (Remote tab for this VM).
