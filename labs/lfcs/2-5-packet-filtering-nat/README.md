# LFCS 2.5: Packet filtering and NAT

firewalld, ufw and nftables, a port redirect, and a NAT gateway for a
private network.

## Before you start

The peer, at `10.99.0.2` (name `peer`), stands in for the other VMs. It sits
on this VM's second network, `10.99.0.0/24` (this VM is `10.99.0.1` there,
on interface `le-host`), and has no route out except through this VM. It
runs its own sshd and a test web server on `10.99.0.2:8000`, and has no
firewalld or ufw. Get a shell there with `sudo ip netns exec lepeer bash`.

On this VM, the lab runs a web service on port 8080 (`le-lab-app`). On the
RHEL family it installs and starts firewalld. Keep a console open: a
firewall mistake can cut off SSH.

## Tasks

1. RHEL family: allow HTTP and HTTPS, remove cockpit, and allow port
   5432/tcp only from `192.168.122.0/24`, all persistently, in the zone of
   the main interface.
2. Ubuntu: turn on ufw allowing only SSH and port 80. From the peer,
   `curl --max-time 5 http://10.99.0.1:8080/` must time out.
3. Write an nftables file for the peer, `/etc/netns/lepeer/nftables.conf`,
   that drops all incoming traffic except replies, loopback, ping and SSH.
   Load it in the peer, and enable `le-lab-peer-nftables.service` (the
   peer's nftables service) so it's loaded at boot.
4. Redirect incoming TCP port 80 on this VM to port 8080, persistently, so
   that `curl http://10.99.0.1/` from the peer reaches the service on 8080.
   With ufw on, allow the redirected traffic, not port 8080 itself.
5. Make this VM the NAT gateway for its second network, so the peer, with
   no other route out, can `ping -c1 9.9.9.9`. Make it persistent.

## Hints

- `firewall-cmd --permanent`, `--add-service`, `--remove-service`,
  `--add-rich-rule`, `--reload`, `--list-all`.
- `ufw allow`, `ufw enable`, `ufw status verbose`.
- `table inet filter`, `chain input`, `policy drop`, `ct state`;
  `nft -c -f` checks a file; `sudo ip netns exec lepeer nft list ruleset`.
- `firewall-cmd --add-forward-port`; with ufw, a `*nat` section in
  `/etc/ufw/before.rules` and `ct status dnat` (`--ctstate DNAT`).
- `net.ipv4.ip_forward`, masquerade; firewalld zones or policies, or ufw's
  `before.rules`, `/etc/default/ufw` and `/etc/ufw/sysctl.conf`.
