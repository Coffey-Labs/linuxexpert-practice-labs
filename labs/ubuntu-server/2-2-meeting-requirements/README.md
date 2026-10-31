# Ubuntu Server 2.2: Checking a system meets requirements

A script that checks CPUs, memory, disk space and the release, whether
the machine can run VMs, and what already listens on the ports an
application wants.

## Before you start

The lab starts two services of its own that listen on ports the next
application wants, as on a server someone else set up. Reset deletes
your `check.sh` again. Write answers to the files in `/root/lab-answers/`.

## Tasks

1. Write a script `check.sh` in your home directory that prints PASS or
   FAIL for each of: at least 2 CPUs, at least 2 GiB of total memory, at
   least 10 GiB free on `/`, and Ubuntu 24.04, one line each, in that
   order. Each result must match what `nproc`, `free -g`, `df -h /` and
   `/etc/os-release` show by hand.
2. Find out whether this machine could host KVM guests itself (write
   `yes` or `no` to `/root/lab-answers/2-kvm`), and whether it's a virtual
   machine (write what `systemd-detect-virt` prints, such as `kvm` or
   `none`, to `/root/lab-answers/2-virt`).
3. Find whether anything already listens on TCP port 80 or 5432, and on
   which addresses. Write one line per listener to `/root/lab-answers/3`:
   the port, the address and the program's name, such as
   `8080 127.0.0.1 python3`.

## Hints

- `nproc`, `free -g` (or `MemTotal` in `/proc/meminfo`), `df -BG /` (or
  `df --output=avail`), `. /etc/os-release` and `$VERSION_ID`; `[ ... ]`,
  `if`, `echo`.
- `lscpu | grep -i virtualization`, `grep -Ec 'vmx|svm' /proc/cpuinfo`;
  `systemd-detect-virt`.
- `sudo ss -tlnp`; `0.0.0.0` means every IPv4 address.
