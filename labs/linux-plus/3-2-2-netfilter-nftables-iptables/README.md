# Linux+ 3.2.2: Netfilter, nftables and iptables

A small nftables table with a set, a counter, and blocking one address.

## Before you start

The peer, at `10.99.0.2` (name `peer`), stands in for the other VM. It sits
on this VM's second network, `10.99.0.0/24` (this VM is `10.99.0.1` there,
on interface `le-host`). Get a shell there with
`sudo ip netns exec lepeer bash`. The lab installs nftables if it's
missing. The rules in this lab are runtime only: a reboot clears them, so
do the tasks and check in one go.

## Tasks

1. Look at what's there (`nft list ruleset`, `iptables -V`). Then write
   an nftables file, `/tmp/lab.nft`, with a table `inet lab` that has a
   set `blocked` of IPv4 addresses and a chain `input` (filter hook input,
   priority 0, policy accept) that counts and drops packets from addresses
   in `blocked`, and counts packets to TCP port 8080. Check the file, load
   it, and list the table.
2. Add the peer's address to `blocked`. From the peer, `ping -c 3
   10.99.0.1` gets no replies. List the set and the chain, and see the
   drop counter go up.

## Hints

- `table inet lab { set blocked { type ipv4_addr; } chain input { type
  filter hook input priority 0; policy accept; ... } }`
- `ip saddr @blocked counter drop`, `tcp dport 8080 counter`.
- `nft -c -f FILE` checks a file; `nft -f FILE` loads it.
- `nft add element inet lab blocked { ADDRESS }`, `nft list set`,
  `nft list chain`.
