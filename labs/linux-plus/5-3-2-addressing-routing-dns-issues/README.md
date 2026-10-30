# Linux+ 5.3.2: Addressing, routing and DNS problems

Working through the layers: the route a packet takes, a missing default
route, and a name that resolves to the wrong address.

## Before you start

The peer, at `10.99.0.2` (name `peer`), is another machine on this VM's
second network, `10.99.0.0/24`; this VM, `10.99.0.1`, is its gateway. Get a
shell there with `sudo ip netns exec lepeer bash`. From the peer,
`198.51.100.9` stands in for an internet address such as `9.9.9.9`. The
peer reads its network settings at boot from `/etc/netns/lepeer/network`
(`ip -batch` commands), so fix that file as well as the running system.
The lab has also changed something on this VM. Task 3 needs the internet.
Write answers to the files in `/root/lab-answers/`.

## Tasks

1. Walk the method on this VM: addresses, routes, the gateway, an internet
   address, a name, a port. Write the gateway address and the interface
   this VM uses to reach `9.9.9.9` to `/root/lab-answers/1`.
2. The peer can't reach `198.51.100.9`. Find out why from the error, and
   fix it, now and at boot.
3. On this VM, `www.kernel.org` resolves to a wrong address for most
   programs, but `dig` gets the right one. Find out where the wrong address
   comes from, write that source to `/root/lab-answers/3`, and fix it.
4. Compare IPv4 and IPv6 to `www.kernel.org` (`dig AAAA`, `curl -4`,
   `curl -6`). Not graded.

## Hints

- `ip -br addr`, `ip route`, `ip route get 9.9.9.9`, `ping`, `getent
  hosts`, `nc -zv`.
- "Network is unreachable" means no route; `ip route add default via`.
  Lines in the peer's file are `ip` commands without the `ip`.
- `getent hosts` follows `/etc/nsswitch.conf`; `dig` asks the DNS server
  only (`dnf install bind-utils` or `apt install dnsutils` if it's
  missing).
