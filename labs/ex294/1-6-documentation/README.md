# EX294 1.6: Using the documentation

Find modules, options, examples and filters with `ansible-doc`, and turn
an example from a module's page into a working task.

## Before you start

This VM is the control node. The lab installs `ansible-core` and creates
the user `greg` (password `Lab-Pass-1`), who has an SSH key. Work as greg
(`su - greg` as root), in `/home/greg/ansible`: its `ansible.cfg` reads the
inventory `inventory`, which has `node1` in the group `nodes`, and logs in
as `ansible`. Answers go in `/root/lab-answers/<task>`, which the
lab creates; write them as root.

The managed node `node1` (10.99.1.11) is an AlmaLinux 10 container with its
own users and packages, reached over SSH by name. The user `ansible`
accepts greg's key and may use sudo without a password. For a root shell
on it, `sudo podman exec -it node1 bash`.

## Tasks

1. As greg, install the `ansible.posix` collection from Ansible Galaxy.
   Then, using only `ansible-doc`, find the module that manages SELinux
   booleans and the option that makes the change persistent. Write the
   module's full name and the option's name to `/root/lab-answers/1`.
2. Find an example in `ansible.builtin.lineinfile`'s page that changes a
   line matched by a regular expression, and adapt it in
   `/home/greg/ansible/sshd.yml` to set `PermitRootLogin no` in node1's
   `/etc/ssh/sshd_config`. The task runs, and a second run reports `ok`.
3. List the filters available on the control node and find the one that
   hashes passwords. Write its name to `/root/lab-answers/3`.

## Hints

- `ansible-galaxy collection install ansible.posix` (it needs the
  internet); `ansible-doc -l | grep -i selinux`, then `ansible-doc MODULE`.
  For a module that isn't installed, `ansible-doc` only warns.
- In the pager, `/EXAMPLES` jumps to the examples. The task needs
  `become: true`, and sshd reads the change only after a reload (a
  handler).
- The node's sshd also reads `/etc/ssh/sshd_config.d/01-le-lab.conf`,
  which lets root log in for the lab and wins over the main file; leave it.
  `sshd -T | grep -i permitroot` shows what sshd really uses.
- `ansible-doc -t filter -l | grep -i password`.
