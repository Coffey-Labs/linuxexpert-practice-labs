# EX294 6.2: Development containers

Give a project a podman development container, run playbooks against the
managed nodes from inside it, and bring it up without VS Code.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) with an SSH key, installs `ansible-core` and `npm`, and
pulls the image `ghcr.io/ansible/community-ansible-dev-tools:latest`
(public, no login) into greg's podman. Work as greg, in
`/home/greg/ansible`: its `ansible.cfg` reads the inventory `inventory`,
logs in as `devops` and becomes root. `site.yml` checks every node and
adds a line to the node's `/var/log/lab-runs.log` with the playbook's
directory, the ansible-core version, and whether it ran in VS Code's
terminal.

For tasks 1 and 2 you need VS Code on your own computer with the Remote -
SSH and Dev Containers extensions: connect to this VM as greg (with his
password, or add your key to his `~/.ssh/authorized_keys`), open
`/home/greg/ansible`, and set **Dev > Containers: Docker Path** to
`podman`.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers reached over SSH by name; on both, `devops`
accepts greg's key and may use sudo without a password. For a root shell
on a node, `sudo podman exec -it node1 bash`.

## Tasks

1. Add a podman `.devcontainer/devcontainer.json` to
   `/home/greg/ansible` that uses the image above, open the project in VS
   Code with **Reopen in Container**, and run `ansible --version` in its
   terminal: the config file is under `/workspaces/`, and the version is
   the image's, not this VM's.
2. Run `site.yml` against the managed nodes from inside the container. It
   fails with "Permission denied (publickey...)" until you forward your
   agent or mount greg's `~/.ssh` into the container; then it succeeds.
3. Without VS Code, install the devcontainer CLI (`npm install -g
   @devcontainers/cli`, as root), bring the same container up with
   `devcontainer up`, and run `site.yml` with `devcontainer exec`. The
   recap matches the run from VS Code.

## Hints

- **Ansible: Create a Devcontainer** in the Command Palette writes the
  podman file; its `runArgs` let tools start containers inside it.
- `"mounts": ["source=${localEnv:HOME}/.ssh,target=/root/.ssh,type=bind,readonly"]`,
  then **Dev Containers: Rebuild Container** (or `devcontainer up
  --remove-existing-container`), since mounts apply only to a new
  container.
- `devcontainer up --workspace-folder . --docker-path podman`, and the
  same options for `devcontainer exec`.
