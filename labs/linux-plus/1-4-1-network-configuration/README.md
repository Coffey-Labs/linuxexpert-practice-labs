# Linux+ 1.4.1: Network configuration

How names are resolved, and a second address on an interface: with
NetworkManager on the RHEL family, with a Netplan file on Ubuntu.

## Before you start

So that you never touch the interface you're connected over, the lab adds a
practice interface, `lab0` (a dummy device, with nothing on the other end).
On the RHEL family it's NetworkManager connection `lab0`, with the address
`192.168.76.1/24`. On Ubuntu, systemd-networkd creates it with no address.
It comes back at every boot. Use `lab0` wherever the chapter uses your main
connection or interface.

## Tasks

1. Make the name `labtest` resolve to `10.99.99.99` without DNS. Check it
   with `getent hosts labtest`, and see that `dig +short labtest` (which
   only asks DNS) doesn't find it. Leave the line in place until you've run
   `le-lab check`.
2. RHEL family: add a second address, `192.168.77.10/24`, to connection
   `lab0`, keeping the first, and bring the connection up again.
3. Ubuntu: give `lab0` the address `192.168.77.10/24` with a new Netplan
   file, `/etc/netplan/90-lab.yaml`, readable only by root, and apply it
   with `netplan try`.

When `le-lab check` passes, take the line and the address out again as the
chapter shows, or leave it to `le-lab reset`.

## Hints

- `/etc/resolv.conf`, the `hosts:` line in `/etc/nsswitch.conf`,
  `/etc/hosts`. On the RHEL family, `dig` is in `bind-utils`.
- `nmcli -t -f NAME,DEVICE con show --active`,
  `nmcli con mod NAME +ipv4.addresses ...`, `nmcli con up NAME`,
  `ip -br addr`.
- An `ethernets:` entry for `lab0` with `addresses: [...]`; `chmod 600`;
  `netplan try` (press Enter to keep it), `netplan status`.
