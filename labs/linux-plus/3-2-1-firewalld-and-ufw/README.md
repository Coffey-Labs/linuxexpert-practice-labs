# Linux+ 3.2.1: firewalld and ufw

Runtime and permanent firewalld rules, a rich rule for one source address,
and ufw.

## Before you start

The peer, at `10.99.0.2` (name `peer`), stands in for the other VM. It sits
on this VM's second network, `10.99.0.0/24` (this VM is `10.99.0.1` there,
on interface `le-host`). It also has a second address, `10.99.0.3`, which
stands in for "anywhere else". Get a shell there with
`sudo ip netns exec lepeer bash`; from it, `curl --interface 10.99.0.3`
sends from the second address.

On this VM, the lab runs web services on ports 8080 and 9000. On the RHEL
family it installs and starts firewalld, allowing SSH. Keep a console open:
a firewall mistake can cut off SSH.

## Tasks

1. RHEL family: allow HTTP in firewalld at runtime, reload and see it gone,
   then allow it permanently, in the zone of the main interface.
2. RHEL family: with a rich rule, allow port 8080/tcp only from the peer's
   address `10.99.0.2`, persistently. From the peer, `curl
   http://10.99.0.1:8080/` works, and from `10.99.0.3` it fails.
3. Ubuntu: turn on ufw, allowing OpenSSH first.
4. Ubuntu: allow port 9000/tcp only from the peer's address `10.99.0.2`.
   From the peer, `curl http://10.99.0.1:9000/` works, and from
   `10.99.0.3` it fails. Look at the rules with `ufw status numbered`.

## Hints

- `firewall-cmd --add-service`, `--permanent`, `--reload`,
  `--list-services`, `--get-active-zones`.
- `--add-rich-rule='rule family="ipv4" source address="..." port
  port="8080" protocol="tcp" accept'`, `--list-rich-rules`.
- `ufw allow OpenSSH`, `ufw enable`, `ufw status verbose`.
- `ufw allow from ADDRESS to any port PORT proto tcp`, `ufw delete N`.
