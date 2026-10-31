# LFCA 2.2: Best practices

Turning off a service nobody needs, a runbook, a script for a manual task,
and a first Ansible playbook.

## Before you start

Work as root (`sudo -i`), so `~` is `/root`. The lab starts a service this
VM doesn't need, listening on TCP port 7070, and creates group
`developers`. It notes whether nginx and Ansible are installed, and reset
puts that back. The VM needs internet access to install packages.

## Tasks

1. Check which services listen on the network with `ss -tulpn`. Find the
   one on port 7070, which this VM doesn't need, and turn it off now and at
   boot.
2. Write a runbook for restarting nginx and checking it came back, then
   have someone else follow it. Not graded.
3. Turn a three-step manual task into a shell script: write
   `/root/add-dev.sh` that takes a user name, creates that user, adds them
   to group `developers`, and creates a directory `/srv/NAME` they own.
   Make it executable and run it for user `erin`.
4. Install Ansible (the `ansible` package on Ubuntu, `ansible-core` on the
   RHEL family). In `/root/ansible`, make an inventory file `inventory`
   with a `[webservers]` line followed by
   `localhost ansible_connection=local`, and save the chapter's nginx
   playbook as `playbook.yml`. Run it against the VM with
   `ansible-playbook -i inventory -K playbook.yml`, twice, and compare the
   output.

## Hints

- `ss -tulpn` shows the process; `systemctl status PID` shows its unit.
  `systemctl disable --now UNIT`.
- `#!/bin/bash` first, `$1` is the name; `useradd -m`, `usermod -aG` (or
  `useradd -G`), `mkdir`, `chown`; `chmod +x`.
- `dnf install ansible-core` / `apt install ansible`. The playbook's
  `hosts: webservers` matches the inventory's group; `-K` asks for the sudo
  password (as root, just press Enter). The second run should show
  `changed=0`.
