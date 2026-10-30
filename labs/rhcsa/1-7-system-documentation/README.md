# RHCSA 1.7: System documentation

Man page sections, finding a setting without the internet, the man page
index, and the documentation a package installs.

## Before you start

The lab moves the man page index away (`/var/cache/man/index.db`), so
`man -k` and `whatis` find nothing until you rebuild it in task 3. Write
your findings to the files in `/root/lab-answers/` named in the tasks.

## Tasks

1. Find which man page section documents the format of `/etc/crontab`,
   and open that page. Write the section number to `/root/lab-answers/1`.
2. Without the internet, find the `sshd_config` keyword that sets the
   maximum number of authentication attempts per connection. Write the
   keyword and its current value, as `sshd -T` shows them (for example
   `logingracetime 120`), to `/root/lab-answers/2`.
3. As root, rebuild the man page index, then search it for timers.
   `man -k timer` should list `systemd.timer (5)`.
4. List every documentation file installed by the `sudo` package and find
   its example sudoers file. Write its full path to `/root/lab-answers/4`.

## Hints

- `man -k crontab` and `whatis crontab` need the index (task 3);
  `man -aw crontab` lists the pages without it. Section 5 is file formats.
- `man sshd_config`, then `/` to search; `sudo sshd -T | grep -i`.
- `mandb`.
- `rpm -qd sudo`.
