# EX294 4.1: ansible-playbook and ansible-navigator

Run the same playbook with ansible-playbook and with ansible-navigator,
browse a run in navigator's interactive mode, and see which files an
execution environment can read.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) with an SSH key, and installs `ansible-core` and
`ansible-navigator` (from PyPI, in `/opt/le-lab-navigator`). Work as
greg, in `/home/greg/ansible`: its `ansible.cfg` reads the inventory
`inventory`, logs in as `devops` and becomes root, and its
`ansible-navigator.yml` uses the execution environment image
`localhost/lab-ee:2.16` (built on this VM from AlmaLinux 10's ansible-core
and collections from Ansible Galaxy; no registry or login) and never
pulls. It doesn't set the mode, so navigator starts in interactive mode
unless you give `-m stdout`.

`site.yml` checks every node and adds a line to the node's
`/var/log/lab-runs.log` saying which command ran it, where Ansible ran,
and the `--limit`. The lab also leaves a note for task 3 in
`/tmp/lab-note.txt`.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers reached over SSH by name; on both, `devops`
accepts greg's key and may use sudo without a password. For a root shell
on a node, `sudo podman exec -it node1 bash`.

## Tasks

1. Run `site.yml` with `ansible-playbook`, then with `ansible-navigator
   run` in stdout mode, limited to one node. Both recaps show the same
   counts for that node.
2. Run `site.yml` with navigator in interactive mode and open the result
   of one task. Not graded: check that the task screen shows `changed:`
   and the module's arguments under `invocation`.
3. Write `/home/greg/ansible/note.yml`, a playbook for `localhost` that
   prints the note's contents with a `file` lookup, and run it with both
   commands. ansible-playbook prints it from `/tmp`; navigator can't find
   it there. Copy the note into the project and point the lookup at the
   copy, so both commands print it.

## Hints

- `--limit node1`, `-m stdout`. In interactive mode, type a row's number
  (`:0`) to open it, Esc to go back, `:q` to quit.
- `lookup('ansible.builtin.file', 'PATH')` in a `debug` task's `msg`.
- The execution environment sees the project directory and `~/.ssh`, not
  the rest of the control node. A relative path in a `file` lookup is
  looked for next to the playbook (and in `files/`).
