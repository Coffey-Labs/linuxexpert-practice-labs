# LFCS 2.6: Static routing

Persistent static routes with NetworkManager and netplan, longest-prefix
matching, keeping a second interface from adding a default route, and a
host that routes between two networks.

## Before you start

The lab gives this VM a second network interface, `le-net2`, with address
`10.98.0.1/24`: a NetworkManager profile called `le-net2` on the RHEL
family, `/etc/netplan/60-le-net2.yaml` on Ubuntu. Its gateways
`10.98.0.254` and `10.98.0.253` don't need to answer for tasks 1 to 4.

For task 5 there are two more machines: the peer at `10.99.0.2` (network
`10.99.0.0/24`, this VM is `10.99.0.1` there) and `far` at `10.97.0.2`
(network `10.97.0.0/24`, this VM is `10.97.0.1` there). Neither has a
default route. Get a shell on them with `sudo ip netns exec lepeer bash`
and `sudo ip netns exec le-far bash`. They read their network settings at
boot from `/etc/netns/lepeer/network` and `/etc/netns/le-far/network`
(`ip -batch` commands, without the leading `ip`).

## Tasks

1. RHEL family: give this VM a persistent route to `10.20.0.0/16` through
   `10.98.0.254`, on its second network.
2. Ubuntu: do the same with netplan.
3. Add a more specific route, `10.20.5.0/24`, through a different gateway,
   `10.98.0.253`, persistently. Predict which gateway `10.20.5.9` and
   `10.20.6.9` go through, and write them to `/root/lab-answers/3`, one per
   line, in that order.
4. RHEL family: make the `le-net2` profile never install a default route,
   so that `ip route` shows one default route, through the main interface.
5. Make this VM route between the peer's network and far's network, and
   give the peer and far routes to each other's network through it, all
   persistent, so they can ping each other and `tracepath` shows this VM
   as the first hop.

## Hints

- `nmcli connection modify le-net2 +ipv4.routes "NETWORK GATEWAY"`, then
  `nmcli connection up le-net2`.
- `routes:` with `to:` and `via:` in netplan, then `netplan apply`.
- `ip route get ADDRESS`.
- `ipv4.never-default`.
- `net.ipv4.ip_forward = 1` in a file in `/etc/sysctl.d/`; a firewall
  must allow forwarding too, if one runs. `tracepath -n`.
