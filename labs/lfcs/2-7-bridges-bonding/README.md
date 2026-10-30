# LFCS 2.7: Bridges and bonding

An active-backup bond, a bridge carrying the host's address, and a guest
attached to the bridge.

## Before you start

Instead of extra network cards, the lab gives this VM four extra
interfaces, each cabled to a small lab network:

- `le-b0` and `le-b1` both go to one switch, where a machine answers at
  `10.96.0.254`.
- `le-p0` goes to another network, `10.95.0.0/24`, where a machine called
  `lan` has `10.95.0.2`. `le-p0` has this VM's address there,
  `10.95.0.1/24`: a NetworkManager profile called `le-p0` on the RHEL
  family, `/etc/netplan/60-le-lab.yaml` on Ubuntu.
- `le-vnet0` is a guest's cable, the way libvirt connects a VM through a
  `vnet` interface. The guest has `10.95.0.50/24`; it's connected to
  nothing yet.

Run commands on the switch, `lan` and the guest with
`sudo ip netns exec le-sw|le-lan|le-guest COMMAND`. Your SSH connection
doesn't use any of these interfaces.

## Tasks

1. RHEL family: create an active-backup bond, `bond0`, from `le-b0` and
   `le-b1`, with the static address `10.96.0.1/24`, persistently.
2. Ubuntu: do the same with netplan.
3. Create a bridge `br0` with `le-p0` as its port and this VM's address on
   that network, `10.95.0.1/24`, moved to the bridge, persistently.
4. Attach the guest to `br0` (add `le-vnet0` as a second port), so it's on
   the `10.95.0.0/24` network and `lan` can reach it at `10.95.0.50`.

## Hints

- `nmcli connection add type bond ... bond.options "mode=...,miimon=..."`,
  then one `type ethernet` profile per member with `master`.
- `bonds:` with `interfaces:` and `parameters:` in netplan; members under
  `ethernets:`.
- `cat /proc/net/bonding/bond0`; to test failover, take the active
  member's other end down: `sudo ip netns exec le-sw ip link set le-b0s
  down` (or `le-b1s`), ping `10.96.0.254`, then bring it back up.
- `nmcli connection add type bridge ... bridge.stp no`, or `bridges:` in
  netplan with `stp: false`; take the address off `le-p0`'s own profile.
- `bridge link`, `ip -br addr`, `sudo ip netns exec le-lan ping 10.95.0.50`.
