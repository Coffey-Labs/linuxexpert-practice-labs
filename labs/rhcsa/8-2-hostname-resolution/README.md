# RHCSA 8.2: Hostname resolution

The hostname, a name in `/etc/hosts`, and a DNS server and search domain
set the NetworkManager way.

## Before you start

The lab gives this VM a spare network interface, `eth1`, cabled to a small
lab network, `192.168.50.0/24`, with a profile called `eth1` that gives it
the address `192.168.50.10/24` and no DNS settings. It comes back at every
boot. Your SSH connection doesn't use it: set DNS on the `eth1` profile,
and leave the main interface's profile alone. A DNS server on `eth1` ranks
below the main interface's (the lab sets that up in
`/etc/NetworkManager/conf.d/`), so name lookups keep working.

The lab notes your hostname and puts it back when you reset it.

## Tasks

1. Set the hostname to `server1.example.com`, persistently.
2. Make the name `web1` (and `web1.example.com`) resolve to
   `192.168.50.20` on this system only, so that `getent hosts web1` prints
   `192.168.50.20   web1.example.com web1`.
3. Make the system use DNS server `192.168.50.1` and search domain
   `example.com` (on the `eth1` profile), so that after
   `nmcli connection up` and a reboot, `/etc/resolv.conf` has
   `nameserver 192.168.50.1` and `search example.com`.

## Hints

- `hostnamectl set-hostname`; `hostname`, `hostname -s`.
- `/etc/hosts`: address, full name, then the short name.
- `nmcli connection modify eth1 ipv4.dns ... ipv4.dns-search ...`, then
  `nmcli connection up eth1`. Don't edit `/etc/resolv.conf` by hand:
  NetworkManager rewrites it.
