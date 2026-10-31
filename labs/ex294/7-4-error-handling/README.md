# EX294 7.4: Error handling

Recover from a failure with `block` and `rescue`, decide what counts as a
failure, and stop a whole play when one host fails.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) and installs `ansible-core`. Work as greg, in
`/home/greg/ansible`: its `ansible.cfg` reads the inventory `inventory`,
logs in to the nodes as `devops` with greg's SSH key, and becomes root.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers, in the group `nodes`. For a root shell on a node,
`sudo podman exec -it node1 bash`.

## Tasks

1. Write `/home/greg/ansible/block.yml` for all nodes: a block that tries
   to start a service that doesn't exist, a `rescue` that prints the
   failed task's name and message, and an `always` that appends a line to
   `/var/log/block.log`. The recap shows `rescued=1` and `failed=0` on
   every node, and the log file has the line.
2. Write `/home/greg/ansible/grep.yml`, which runs `grep` on the nodes for
   a pattern that isn't in the file, such as `lab-pattern`, in the file
   named by the variable `grep_file` (by default `/etc/hosts`). Make the
   task fail only if the file is missing: the playbook passes as it is,
   and fails with `-e grep_file=/etc/no-such-file`.
3. Write `/home/greg/ansible/stop.yml`: a play on all nodes with a task
   that fails on node1 only, then at least one more task. Make the play
   stop on every host as soon as node1 fails: the output shows
   `NO MORE HOSTS LEFT`, and the later tasks run on no host.

## Hints

- In `rescue`, `ansible_failed_task.name` and `ansible_failed_result.msg`.
- `lineinfile` with `create: true` makes the log file if it's missing.
- `grep` exits 0 on a match, 1 on none and 2 on an error such as a
  missing file; register the result and use `failed_when` on its `rc`.
  `ignore_errors` doesn't change what a failure is.
- `/bin/false` with `when: inventory_hostname == 'node1'`, and a play
  keyword from the chapter's table.
