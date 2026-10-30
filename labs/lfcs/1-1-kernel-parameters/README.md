# LFCS 1.1: Kernel parameters

Changing kernel parameters now and for good, a per-interface IPv6 setting,
a boot parameter, and module options.

## Before you start

The lab turns IPv4 forwarding off and makes sure `vm.swappiness` isn't 10.
It adds two linked network interfaces, `lab0` and `lab1`, which come back at
every boot; NetworkManager and networkd leave them alone. The `dummy` module
is unloaded. Reboot when a task says so; the check looks at the running
system.

## Tasks

1. Turn on IPv4 forwarding until the next reboot only. Check it yourself:
   `sysctl net.ipv4.ip_forward` shows `1` now and `0` after a reboot. Do
   this one before task 2.
2. Make IPv4 forwarding permanent, and set `vm.swappiness` to `10`, in a
   file named `/etc/sysctl.d/90-lab.conf`, without rebooting.
3. Disable IPv6 on interface `lab0` only, persistently. After a reboot,
   `lab0` has no IPv6 addresses while `lab1` and the other interfaces keep
   theirs.
4. Add the boot parameter `audit=1` to every installed kernel, then reboot.
5. Make the `dummy` module load at every boot with two devices, then
   reboot. `ip -br link | grep -c dummy` should print `2`.

## Hints

- `sysctl -w`, `/proc/sys`.
- A `.conf` file in `/etc/sysctl.d/`, then `sysctl --system`.
- Per-interface keys look like `net.ipv6.conf.NAME.disable_ipv6`.
- `grubby` on RHEL relatives; `/etc/default/grub` and `update-grub` on
  Ubuntu. `/proc/cmdline` after the reboot.
- `modinfo -p dummy`, `/etc/modprobe.d/`, `/etc/modules-load.d/`. Files in
  every `modprobe.d` directory are read in name order and the last setting
  wins; `modprobe --show-depends dummy` shows what modprobe will pass.
