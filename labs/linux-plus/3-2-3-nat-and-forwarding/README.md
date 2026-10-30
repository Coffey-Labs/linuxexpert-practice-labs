# Linux+ 3.2.3: NAT and IP forwarding

Turning this VM into a router for a private network with firewalld zones,
a policy and masquerading.

## Before you start

RHEL family only. The peer, at `10.99.0.2`, stands in for the Ubuntu VM.
It sits on this VM's second network, `10.99.0.0/24` (this VM is
`10.99.0.1` there, on interface `le-host`), and its default route already
points at this VM, but it has no way out yet: from the peer,
`ping -c 2 9.9.9.9` fails. Get a shell there with
`sudo ip netns exec lepeer bash`.

The lab installs and starts firewalld, allowing SSH. The interface
`le-host` isn't managed by NetworkManager, so set its zone with
`firewall-cmd` rather than `nmcli`. Keep a console open: a firewall mistake
can cut off SSH.

## Tasks

1. Put `le-host` in firewalld's `internal` zone, persistently.
2. Create a firewalld policy `int-to-pub` that accepts traffic from zone
   `internal` to zone `public`, and turn on masquerading in the zone of
   the main interface, both persistently. Check `net.ipv4.ip_forward`.
3. From the peer, `ping -c 2 9.9.9.9` now works. Watch the translation on
   this VM with `tcpdump -ni any icmp` while it runs.

## Hints

- `firewall-cmd --permanent --zone=internal --change-interface=le-host`,
  `--get-active-zones`.
- `firewall-cmd --permanent --new-policy NAME`, then `--policy NAME` with
  `--add-ingress-zone`, `--add-egress-zone` and `--set-target=ACCEPT`
  (firewalld 2.4 takes one of these per command); `--info-policy NAME`.
- `--zone=public --add-masquerade`, with `--permanent` too;
  `--reload`.
