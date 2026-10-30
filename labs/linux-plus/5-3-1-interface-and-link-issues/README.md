# Linux+ 5.3.1: Interface and link problems

A link that's down, an MTU mismatch, a dummy interface, and an address
conflict.

## Before you start

The peer, at `10.99.0.2` (name `peer`), is another machine on this VM's
second network, `10.99.0.0/24`; this VM is `10.99.0.1` there, on interface
`le-host`. Get a shell there with `sudo ip netns exec lepeer bash`. The lab
has broken a few things on that network. None of it lasts past a reboot:
do the tasks and check without rebooting. Leave your main interface alone.
Write answers to the files in `/root/lab-answers/`.

## Tasks

1. Read your links' details and counters. This VM can't reach the peer
   (`ping 10.99.0.2`): find out why at the link level and fix it.
2. Small pings to the peer work, but big packets never arrive. Find the
   largest packet (the MTU, IP header included) that gets from this VM to
   the peer with "don't fragment" set, and write it to
   `/root/lab-answers/2`.
3. Create a dummy interface `lab0` with address `192.0.2.10/24` and MTU
   1400, bring it up, then take its link down again. Leave it there.
4. You want to add `10.99.0.5` to `le-host`. First check whether another
   host on that network already uses it, and write the MAC address of the
   host that answers to `/root/lab-answers/4`.

## Hints

- `ip -br link`, `ip -br addr`, `ip -s link show`, `ethtool`; `ip link
  set DEV up`.
- `ping -c1 -M do -s SIZE` (SIZE + 28 is the packet size), `tracepath -n`.
- `ip link add NAME type dummy`, `ip addr add`, `ip link set NAME up mtu
  1400`, `ip link set NAME down`.
- `arping -D -c 2 -I le-host ADDRESS` (on Ubuntu, install
  `iputils-arping`); exit 0 means nobody answered.
