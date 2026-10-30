# LFCS 2.1: IPv4, IPv6 and name resolution

Static addresses, gateways and DNS servers for IPv4 and IPv6, a second
address, the hostname, `/etc/hosts`, and a DNS search domain, all
persistent.

## Before you start

The lab notes the main interface's current address, gateway and DNS server
in `/root/lab-network.txt`. Keep that address, gateway and DNS server in
task 1 or 2 so the VM stays reachable; only the way they're set changes.
Work from the console, not SSH, while you change the main interface, and
take a snapshot first.

## Tasks

1. RHEL family: give the main interface a static IPv4 address, gateway and
   DNS server (the ones in `/root/lab-network.txt`), plus the static IPv6
   address `2001:db8:10::20/64` with gateway `2001:db8:10::1`, all
   persistent, with NetworkManager.
2. Ubuntu: do the same with netplan.
3. Add a second IPv4 address, `192.0.2.21/24`, to the main interface
   without removing the first, persistently.
4. Set the hostname to `lab1.example.org`, and make `db1` resolve to
   `192.168.122.30` without DNS.
5. Add `example.org` as a DNS search domain, persistently, so that
   `getent hosts www` resolves `www.example.org`.

## Hints

- `nmcli connection modify` with `ipv4.method manual`, `ipv4.addresses`,
  `ipv4.gateway`, `ipv4.dns`, and the same for `ipv6`; then
  `nmcli connection up`.
- On Ubuntu, cloud-init writes `/etc/netplan/50-cloud-init.yaml`: edit it
  (or override it in a file that sorts later), tell cloud-init to leave the
  network alone, then `netplan try` or `netplan apply`.
- `+ipv4.addresses` adds an address; in netplan, `addresses:` is a list.
- `hostnamectl set-hostname`, `/etc/hosts`, `getent hosts`.
- `ipv4.dns-search`, or `search:` under `nameservers:` in netplan.
- `ip -br addr`, `ip route`, `ip -6 route`, `resolvectl status`.
