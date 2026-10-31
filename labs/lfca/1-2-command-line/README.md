# LFCA 1.2: Command line

Directories, finding files, reading the SSH log, permissions, archives,
two editors, and a script of your own on the `PATH`.

## Before you start

Work as root (`sudo -i`), so `~` is `/root`. Answers go in
`/root/lab-answers/<task>`. The lab creates `~/editme.txt` for task 6 and
saves your `~/.bashrc` and sshd's settings so reset can put them back.
Files in `/tmp` don't survive a reboot, so do the tasks in one go and run
`le-lab check` before you reboot.

## Tasks

1. Make `~/practice/a/b` with one command, move into `b`, and get back home
   three different ways.
2. Find every file under `/etc` whose name ends in `.conf`, save the list to
   `~/conf-files.txt`, count its lines, and write the count to
   `/root/lab-answers/2`.
3. Make sure the SSH server is running and allows password logins (turn
   them on if not), run `ssh localhost` and type a wrong password. Count
   the failures in sshd's journal and write the count to
   `/root/lab-answers/3`.
4. Make a file `/tmp/private.txt` that only you can read and write, check
   it with `ls -l`, then create user `bob` with a home directory and try
   `sudo -u bob cat /tmp/private.txt`.
5. Archive `~/practice` to `~/practice.tar.gz` with `tar -czf`, delete
   `~/practice`, and restore it from the archive.
6. Open `~/editme.txt` in vi, change `before` to `after` on the first line,
   save and quit. Then do the same on the second line in nano (install it
   if it's missing).
7. Add `~/scripts` to `PATH` in `~/.bashrc`, put a script `hello` in it
   with a `#!/bin/bash` first line, make it executable with `chmod u+x`,
   and run it as `hello` in a new shell.

## Hints

- `mkdir -p`, `cd`, `cd ~`, `cd ../../..`, `cd -` and `pwd`.
- `find /etc -name '*.conf' > ~/conf-files.txt`, `wc -l`.
- `systemctl status sshd` (`ssh` on Ubuntu). `sshd -T | grep passwordauth`
  should say `yes`; many cloud images set it to `no`, on Ubuntu in
  `/etc/ssh/sshd_config.d/50-cloud-init.conf`. Change it there and
  `systemctl restart sshd` (`ssh` on Ubuntu).
- `journalctl -u sshd | grep -c "Failed password"` (`-u ssh` on Ubuntu).
- `chmod 600`, `useradd -m bob`; the `cat` should fail.
- `tar -czf ~/practice.tar.gz -C ~ practice`, `rm -r`, `tar -xzf`,
  `tar -tzf` to look inside.
- vi: `i` to insert, Esc, `:wq`. nano: Ctrl-O to save, Ctrl-X to quit.
  `dnf install nano` on the RHEL family.
- `export PATH="$HOME/scripts:$PATH"` in `~/.bashrc`, `bash` or a new login
  to get a new shell, `type hello`.
