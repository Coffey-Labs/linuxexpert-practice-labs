# LPIC-3 334.3: Packet filtering

A stateful host firewall with iptables, logging, a port redirect, an IP
set, saving the rules, and the same job in native nftables.

## Before you start

The peer, at `10.99.0.2` (name `peer`), is the client that tests your
firewall. It sits on this VM's second network, `10.99.0.0/24`, where this
VM is `10.99.0.1` on interface `le-host`. Get a shell there with
`sudo ip netns exec lepeer bash`. The lab runs two small web servers to
protect, on `10.99.0.1:8080` ("site on 8080") and `10.99.0.1:8081`
("site on 8081").

You build the firewall by hand here, so the lab stops firewalld (RHEL
family) or ufw (Ubuntu) if it's running, and reset starts it again. Every
rule set must keep SSH open; keep a console open in case you lock yourself
out. Your rules last only until the next reboot: check before you reboot.
Keep your files in `/root/fw`.

## Tasks

1. Install `iptables` (on the RHEL family, `iptables-nft`), `ipset` and
   the `conntrack` tool. Build a stateful default-deny INPUT chain:
   accept loopback and replies, drop invalid packets, accept new SSH
   connections and pings (limited to 5 a second), accept port 8080 only
   from the peer (with a comment), and log (`FW-DROP: `, at most 10 a
   minute) and drop everything else. From the peer, ping and port 8080
   work, and port 8081 times out; find the logged drop and the tracked
   connections.
2. Make port 8888 on `le-host` reach the server on 8081 with a NAT
   redirect, and accept only the redirected traffic to 8081 from the peer,
   so that 8081 stays closed to direct connections.
3. Make an IP set `blocklist` and a rule, second in INPUT, that drops its
   members. Block the peer by adding it to the set, and unblock it again,
   without changing any rule.
4. Save the rules with `iptables-save` (without its comment lines) to
   `/root/fw/rules.v4`.
5. Switch to native nftables: clear the iptables rules (and set INPUT's
   policy back to accept), destroy the IP set, and load
   `/root/fw/lab.nft`, a table `inet lab` with a set `web_clients`
   holding the peer, and an input chain with policy drop that accepts
   replies, loopback, SSH, ICMP and port 8080 from `@web_clients`, and
   counts, logs (`NFT-DROP: `) and drops the rest. Then delete the peer
   from the set at run time, so that port 8080 is dropped for it too.

## Hints

- `iptables -A INPUT ... -j ACCEPT`, `-m conntrack --ctstate
  ESTABLISHED,RELATED`, `-p icmp --icmp-type echo-request -m limit --limit
  5/second`, `-s 10.99.0.2 -p tcp --dport 8080 -m comment --comment ...`,
  `-j LOG --log-prefix`, `iptables -P INPUT DROP`; `iptables -L INPUT -n -v
  --line-numbers`. From the peer: `curl -s -m 3 http://10.99.0.1:8081/`.
  `journalctl -k | grep FW-DROP`, `conntrack -L`.
- `iptables -t nat -A PREROUTING -i le-host -p tcp --dport 8888 -j
  REDIRECT --to-ports 8081`; `-m conntrack --ctstate DNAT`.
- `ipset create blocklist hash:ip`, `iptables -I INPUT 2 -m set
  --match-set blocklist src -j DROP`, `ipset add`, `ipset del`, `ipset
  test`.
- `iptables-save | grep -v '^#'`; `nft list chain ip filter INPUT`,
  `iptables-translate`.
- `iptables -F`, `iptables -t nat -F`, `iptables -P INPUT ACCEPT`,
  `ipset destroy`; `nft -c -f`, `nft -f`, `nft list table inet lab`,
  `nft delete element inet lab web_clients '{ 10.99.0.2 }'`.
