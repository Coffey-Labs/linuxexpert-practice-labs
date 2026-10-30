# Linux+ 3.3.5: Hardening the system

Finding what listens, setuid and capability-holding programs, a noexec
mount, and a service's hardening score.

## Before you start

The lab has left a few things on this VM for you to find: a service that
listens on the network, a setuid program and a program with a file
capability, none of them installed by a package. Write answers to the
files in `/root/lab-answers/`. Task 4's mount lasts only until a reboot:
do the tasks and check in one go.

## Tasks

1. List what listens and what's enabled. One service listens on TCP port
   2323 for no good reason: find it, and stop and disable it.
2. Find the setuid and setgid programs. Write the path of the setuid
   program that no package installed to `/root/lab-answers/2`.
3. Find the programs that hold file capabilities. Write the path of the
   one that no package installed to `/root/lab-answers/3`.
4. Mount a tmpfs on `/mnt/nx` with `noexec`, `nosuid` and `nodev`. Copy
   `/usr/bin/id` there and see that it can't run. Leave it mounted.
5. Check for pending security updates, and find the overall exposure score
   that `systemd-analyze security` gives the SSH service (`sshd` on the
   RHEL family, `ssh` on Ubuntu). Write the number to
   `/root/lab-answers/5`.

## Hints

- `ss -tulpn`, `systemctl list-unit-files --state=enabled`, `ps -o
  unit= -p PID`; `systemctl disable --now`.
- `find / -xdev -perm -4000 -type f`; `rpm -qf` or `dpkg -S`.
- `getcap -r /usr/bin /usr/sbin`.
- `mount -t tmpfs -o noexec,nosuid,nodev tmpfs /mnt/nx`, `findmnt`.
- `dnf updateinfo list --security` or `apt list --upgradable`;
  `systemd-analyze security UNIT | tail -1`.
