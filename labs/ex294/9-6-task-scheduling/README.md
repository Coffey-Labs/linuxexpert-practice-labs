# EX294 9.6: Task scheduling

Schedule a user's cron job, add and remove a job in `/etc/cron.d`, and
deploy a systemd timer.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) with an SSH key, and installs `ansible-core`. Work as greg,
in `/home/greg/ansible`: its `ansible.cfg` reads the inventory `inventory`,
logs in as `devops` and becomes root. `node1` is in the group `webservers`
and `node2` in `dbservers`.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers, prepared as in chapter 3.1: `devops` takes greg's
key and may use sudo without a password. Both run crond, and node1 has a
user `student`. For a root shell on a node, `sudo podman exec -it node1
bash`.

## Tasks

1. Schedule `logger "EX294 in progress"` for `student` every 2 minutes on
   the web servers. `crontab -l -u student` shows it, and after a few
   minutes `journalctl -t student` on node1 has the messages.
2. Add a job to `/etc/cron.d/backup` on every node that archives `/etc` at
   02:00 every Sunday, as root. The file has the line with `root`. Then
   remove it again from the web servers with `state: absent`; it's gone
   there, and stays on the database servers.
3. Deploy a systemd timer `cleanup.timer` on the database servers that
   runs a cleanup daily. `systemctl list-timers` lists it with a next run
   time.

## Hints

- `ansible.builtin.cron` with `name`, `user`, `minute: "*/2"`, `job`; for
  `/etc/cron.d`, `cron_file` and `user: root`, and `weekday: "0"`.
- `state: absent` finds the job by its `name`, so use the same one.
- A timer is two units: the oneshot service that does the work and the
  timer with `OnCalendar=daily`. Enable and start the timer, after
  `daemon_reload: true`.
