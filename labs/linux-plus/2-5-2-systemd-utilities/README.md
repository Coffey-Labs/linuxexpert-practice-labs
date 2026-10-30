# Linux+ 2.5.2: systemd tools

Setting the hostname and time zone, and changing a kernel parameter now
and for good.

## Before you start

The lab notes the hostname, time zone and `vm.swappiness` it finds, so
that `le-lab reset` can put them back. If the time zone is already UTC,
it sets it to America/Phoenix for now, and if `vm.swappiness` is already
20, it sets it to 60.

## Tasks

1. Set the hostname to `lab-alma.example.test` (on an Ubuntu VM,
   `lab-ubuntu.example.test` is fine too), so that it stays after a
   reboot.
2. Set the time zone to UTC.
3. Set the kernel parameter `vm.swappiness` to 20 now, and in a file in
   `/etc/sysctl.d/` so that it's 20 after a reboot too. (The chapter then
   removes the file again; leave it in place here.)

## Hints

- `hostnamectl`, `hostnamectl set-hostname`, `hostname`.
- `timedatectl list-timezones`, `timedatectl set-timezone`.
- `sysctl -n`, `sysctl -w`, `sysctl --system`.
- The chapter's steps on `resolvectl` (Ubuntu) and `systemd-analyze` aren't
  graded; try them anyway.
