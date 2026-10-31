# Ubuntu Desktop 1.2: Layer 2: MAC addresses, ARP and broadcast

Finding MAC addresses and the maker's prefix, watching an ARP exchange,
and checking that an address is free before you use it.

## Before you start

The lab sets up a second machine, the peer, at `10.99.0.2` (name `peer`).
It's on the same network as this VM's interface `le-host` (`10.99.0.1`),
so the two can talk directly over Ethernet. Two of the addresses
`10.99.0.21`, `10.99.0.22` and `10.99.0.23` are also in use on that
network; one is free. `iputils-arping` isn't installed. Write answers to
the files in `/root/lab-answers/`.

## Tasks

1. Find your machine's MAC address and the maker's prefix in it, and your
   default gateway's MAC address. Use the interface your default route
   goes out of. Write your MAC on line 1 of `/root/lab-answers/1`, the
   prefix (its first three bytes) on line 2, and the gateway's MAC on
   line 3.
2. Empty the neighbor table, then watch the ARP exchange as you ping the
   peer. Write the peer's MAC address, from its reply, to
   `/root/lab-answers/2`.
3. Check which of `10.99.0.21`, `10.99.0.22` and `10.99.0.23` is free
   before giving it to a new machine (install `iputils-arping` first).
   Write the free address to `/root/lab-answers/3`.

## Hints

- `ip -br link`; `ip route | grep default` gives the gateway's IP; after
  `ping -c1` to it, `ip neigh show` lists it with `lladdr` and its MAC.
- `sudo ip neigh flush dev le-host`, then `sudo tcpdump -i le-host -e -n
  arp` in one terminal and `ping -c1 10.99.0.2` in another: look for
  `Request who-has` to `ff:ff:ff:ff:ff:ff` and `Reply ... is-at`.
- `sudo arping -D -c 2 -I le-host ADDRESS; echo $?` prints `Received 0
  response(s)` and `0` for a free address, and a reply and `1` for one in
  use.
