# RHCSA 8.1: IPv4 and IPv6 addresses

Static IPv4 and IPv6 addresses, a gateway and a DNS server on a spare
interface with `nmcli`, a second address, and the same again with `nmtui`.

## Before you start

The lab gives this VM a spare network interface, `eth1`, cabled to a small
lab network, `192.168.50.0/24`, where a machine answers at `192.168.50.1`
(and `fd00:50::1`). It comes back at every boot. `eth1` has no profile
yet. Your SSH connection doesn't use it, so leave the main interface
alone.

A gateway and DNS server on `eth1` rank below the main interface's (the
lab sets that up in `/etc/NetworkManager/conf.d/`), so the VM keeps its
own way out. Profiles come and go in task 3, so the lab runs a small
service, `le-lab-watch`, that notes the profiles for `eth1` for the check.

## Tasks

1. Give `eth1` the static IPv4 address `192.168.50.10/24`, gateway
   `192.168.50.1`, DNS server `192.168.50.1`, and the IPv6 address
   `fd00:50::10/64`, all persistent, in a profile made with `nmcli`.
2. Add a second IPv4 address, `192.168.50.11/24`, to the same profile
   without removing the first.
3. Delete that profile with `nmcli connection delete`, and do tasks 1 and
   2 again with `nmtui` on a fresh profile.

## Hints

- `nmcli connection add type ethernet ifname eth1 con-name eth1
  ipv4.method manual ipv4.addresses ... ipv4.gateway ... ipv4.dns ...
  ipv6.method manual ipv6.addresses ...`.
- `nmcli connection modify NAME +ipv4.addresses ...`, then
  `nmcli connection up NAME`; `nmcli -g ipv4.addresses connection show
  NAME`.
- In `nmtui`, "Edit a connection", "Add", "Ethernet", device `eth1`; set
  IPv4 and IPv6 to "Manual".
- `ip -br addr show eth1`, `ip route`, `cat /etc/resolv.conf`,
  `ping 192.168.50.1`.
