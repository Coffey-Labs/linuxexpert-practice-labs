# Linux+ 3.3.1: sudo and su

A sudo rule for one command, finding a refused command in the log, and
closing a shell escape with NOEXEC.

## Before you start

The lab makes the journal persistent if it isn't, so the log of task 2
survives a reboot. User `sudotest` doesn't exist yet: you create it.

## Tasks

1. Look at your own rights (`sudo -l`) and at `/etc/sudoers` and what it
   includes. Then create user `sudotest` with the password `Lab-Pass-123`,
   and a file `/etc/sudoers.d/sudotest` that lets it run, as root, only
   `systemctl status sshd` and `systemctl status ssh`. Give the file mode
   440 and check the sudo configuration with `visudo -c`.
2. As `sudotest`, list your rights, check the SSH service's status with
   sudo, and try `sudo id`, which is refused. Find the refusal in the
   journal.
3. Also let `sudotest` run `/usr/bin/less /etc/shadow` as root, keeping the
   rule from task 1. Try it and type `!id` in less: you get a root shell
   command. Then change the rule to use `NOEXEC`, so that the shell escape
   is refused.

## Hints

- `useradd -m`, `chpasswd`; `ALL=(root) /usr/bin/systemctl status sshd,
  ...`; `chmod 440`; `visudo -c`.
- `su - sudotest`, `sudo -l`; `journalctl _COMM=sudo --since "10 min ago"`.
- One rule can list several commands, or use one line per command;
  `NOEXEC:` goes before the command it applies to.
