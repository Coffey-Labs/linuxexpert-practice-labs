# LPIC-1 110.1: Security administration tasks

Setuid files, open ports and their processes, user limits, a narrow sudo
rule, and a locked account.

## Before you start

The lab creates users `tess` and `locky` (password `Lab-Pass-1`) and a
service `labweb`. It runs a program that listens on a TCP port, which task
2 finds. The peer, at `10.99.0.2` (name `peer`), stands in for another VM:
get a shell there with `sudo ip netns exec lepeer bash`. If a firewall
runs here, the lab lets the peer through it, so a scan sees every port.

## Tasks

1. List every setuid and setgid file on the root filesystem into
   `/root/lab-answers/1-before`. Copy `/usr/bin/bash` to
   `/usr/local/bin/testbash`, set the setuid bit on the copy, list again into
   `/root/lab-answers/1-after`, and `diff` the two lists. Then delete the
   copy.
2. Scan this VM from the peer with `nmap` (scan `10.99.0.1`), and match
   each open TCP port to a process with `ss -tlnp` and `fuser`. Write one
   line per open port to `/root/lab-answers/2`: the port number and the
   process name, such as `22 sshd`.
3. Give `tess` a hard limit of 50 processes (`nproc`) in
   `/etc/security/limits.conf` or a file in `/etc/security/limits.d/`, log
   in as `tess`, and check `ulimit -u`.
4. Give `tess` permission to run `systemctl restart labweb` with sudo, and
   nothing else. Check with `sudo -l` as `tess`, and try another command.
5. Lock `locky`'s password with `passwd -l`, check `passwd -S`, and try to
   log in as `locky` (for example with `su - locky` as `tess`). Then read
   the attempt with `lastb` or `journalctl`.

## Hints

- `find / -xdev -perm /6000 -type f`; `chmod u+s`; `diff`.
- `nmap` is a package of its own; it runs in the peer with
  `sudo ip netns exec lepeer nmap 10.99.0.1`. `ss -tlnp`, `fuser -n tcp
  PORT`, `ps -p PID -o comm=`.
- `tess hard nproc 50`; `su - tess`, `ulimit -Hu`.
- A file in `/etc/sudoers.d/` checked with `visudo -cf`; the full path of
  `systemctl` (`command -v systemctl`); `sudo -l -U tess`.
- `passwd -S locky`; `journalctl -t su` or `journalctl --since -10min`.
