# LFCS 5.3: User resource limits

Limiting users' processes, open files and logins with pam_limits, changing
the limits of a running process, and capping a user's memory with systemd.

## Before you start

The lab creates group `students` with members `student1` and `student2`,
and user `alice` (password `Lab-Pass-1`, shell bash). Service `lab-worker`
runs a program of the same name as `alice`. So that `le-lab check` can test
`ssh` logins, the lab puts a key in `student2`'s `~/.ssh/authorized_keys`.

## Tasks

1. Limit each member of group `students` to 50 processes. Test it with
   `sudo -iu student1 bash -c 'ulimit -u'`.
2. Give user `alice` an open-file limit of 10000 soft and 20000 hard. Test
   it with `sudo -iu alice bash -c 'ulimit -Sn; ulimit -Hn'`.
3. Allow members of `students` at most two simultaneous logins. Test it
   with three `ssh student1@localhost` sessions at once.
4. Find the open-file limits the running `lab-worker` process has, and
   write them to `/root/lab-answers/4` as two numbers, soft then hard. Then
   raise its open-file limit to 4096, soft and hard, without restarting it.
5. Cap all of `alice`'s processes together at 1 GiB of memory, and only
   hers.

## Hints

- `/etc/security/limits.d/*.conf`: `@group`, `soft`, `hard`, `-`, and the
  items `nproc`, `nofile` and `maxlogins`. They apply at the next login.
- `pgrep`, `/proc/PID/limits`, `prlimit --pid`.
- `systemctl set-property user-UID.slice`; `systemctl show -p MemoryMax`.
