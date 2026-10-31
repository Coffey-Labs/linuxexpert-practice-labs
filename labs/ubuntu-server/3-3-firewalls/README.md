# Ubuntu Server 3.3: Firewalls: ufw and iptables

ufw with a default policy, a rule for one address and a rate limit, and a
plain iptables firewall that lasts over a reboot.

## Before you start

This VM is s1. The peer, at `10.99.0.2` (name `peer`), is s2: it sits on
this VM's second network, `10.99.0.0/24`, where this VM is `10.99.0.1` on
interface `le-host`. It has a second address, `10.99.0.3`, which stands in
for "any other machine". Get a shell there with `sudo ip netns exec lepeer
bash`; from it, `curl --interface 10.99.0.3` sends from the second
address. The peer runs its own sshd and a test web server on
`10.99.0.2:8000`, and has no ufw.

On this VM the lab runs a web server on port 80. It saves ufw's rules and
turns ufw off, so you start from scratch; reset puts them back. Keep a
console open: a firewall mistake can cut off SSH.

The peer is a network namespace, rebuilt at every boot, so its rules can't
be kept by `iptables-persistent` (which would also replace ufw on this
VM). Instead, save them to `/etc/netns/lepeer/iptables.rules`; the lab's
`le-lab-peer-iptables.service`, once enabled, loads that file into the
peer at boot.

## Tasks

1. On s1, with ufw: deny incoming by default, allow SSH from anywhere, and
   allow HTTP only from s2's address. Enable it. `sudo ufw status verbose`
   shows `deny (incoming)` and the two rules; `curl http://10.99.0.1/`
   works from the peer and times out from `10.99.0.3`; your SSH session
   is still alive.
2. Remove the HTTP rule by its number, then rate-limit SSH. `sudo ufw
   status numbered` no longer lists port 80 and shows `LIMIT IN` for SSH;
   seven quick `nc -z 10.99.0.1 22` from the peer leave `[UFW LIMIT
   BLOCK]` lines in `/var/log/ufw.log`.
3. On s2, without ufw, use iptables to allow only loopback traffic, SSH,
   ping and replies to its own connections, dropping everything else, and
   keep the rules over a reboot. After a reboot, `sudo ip netns exec lepeer
   iptables -S INPUT` shows `-P INPUT DROP` and your rules, and `ping -c1
   10.99.0.2` from s1 works.

## Hints

- `ufw default deny incoming`, `ufw allow OpenSSH`, `ufw allow from ADDRESS
  to any port 80 proto tcp`, `ufw enable`, `ufw status verbose`.
- `ufw status numbered`, `ufw delete N`, `ufw limit OpenSSH`;
  `for i in $(seq 7); do nc -z -w1 10.99.0.1 22; done`, `grep 'LIMIT
  BLOCK' /var/log/ufw.log`.
- `iptables -A INPUT -i lo -j ACCEPT`, `-m conntrack --ctstate
  ESTABLISHED,RELATED`, `-p tcp --dport 22`, `-p icmp`, `iptables -P INPUT
  DROP`, all run in the peer. `sudo ip netns exec lepeer iptables-save |
  sudo tee /etc/netns/lepeer/iptables.rules`; `systemctl enable
  le-lab-peer-iptables`.
