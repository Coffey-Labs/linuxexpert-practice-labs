# EX294 2.2: ansible-navigator.yml

Configure ansible-navigator for a project: a local execution environment
image, the pull policy, stdout mode and no artifacts. Then see what a bad
pull policy and a run without the execution environment do.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) with an SSH key, and installs `ansible-core` and
`ansible-navigator` (from PyPI, in `/opt/le-lab-navigator`). Work as
greg, in `/home/greg/ansible`: its `ansible.cfg` reads the inventory
`inventory`, logs in as `devops` and becomes root, and `site.yml` is a
playbook for every node.

greg's podman has one execution environment image, `localhost/lab-ee:2.16`,
built here from public parts, the way the chapter's "Getting navigator
and an image" shows: AlmaLinux 10's ansible-core with the `ansible.posix`
and `community.general` collections from Ansible Galaxy.
It exists only on this VM, in no registry, and needs no login.
`podman images` (as greg) lists it.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers reached over SSH by name; on both, `devops`
accepts greg's key and may use sudo without a password. For a root shell
on a node, `sudo podman exec -it node1 bash`.

## Tasks

1. Write `/home/greg/ansible/ansible-navigator.yml` so that navigator uses
   the image `localhost/lab-ee:2.16`, never pulls, runs in stdout mode and
   writes no playbook artifacts. `ansible-navigator settings --effective
   --sources` shows `Settings file` for each of them, and
   `ansible-navigator run site.yml` prints plain playbook output.
2. Run `site.yml` once with the pull policy `always` (`--pp always`) and
   read the error. Write the line navigator stops with to
   `/root/lab-answers/2` (as root).
3. Run `site.yml` with the execution environment turned off
   (`--ee false`). Which module fails, and why? Write its full name to
   `/root/lab-answers/3` (as root).

## Hints

- Everything sits under the top-level `ansible-navigator:` key, and
  setting names use hyphens: `execution-environment` (`image`,
  `pull: policy:`), `mode`, `playbook-artifact` (`enable`).
- `ansible-navigator settings --sample` prints a commented example of
  every setting. A key that shows `Defaults` in `--sources` is misspelled
  or in the wrong place.
- `--ee false` runs the control node's own ansible-core, with only the
  collections installed here; `ansible-galaxy collection list` shows them.
