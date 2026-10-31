# LPIC-3 334.1: Network hardening

A RADIUS server and what its traffic looks like, a rogue router
advertisement, and a rogue DHCP server.

## Before you start

The peer, at `10.99.0.2` (name `peer`), stands in for the other VM, on
this VM's second network, `10.99.0.0/24` (this VM is `10.99.0.1` there,
on interface `le-host`). It plays the RADIUS client (the access point) and
the victim of your rogue router. Get a shell there with
`sudo ip netns exec lepeer bash`; it shares this VM's files and programs.

Somebody has also put a rogue DHCP server on that network. Write answers
to the files in `/root/lab-answers/`. The firewall, if it's running, is
yours to open. The wireless parts of the chapter need real Wi-Fi hardware
and aren't part of this lab.

## Tasks

1. Install FreeRADIUS and its client tools (`freeradius-utils`). Let the
   server accept requests from `10.99.0.0/24` with the secret
   `lab-radius-secret`, add the user `alice` with the password
   `alice-lab-pass` and the reply message `Hello, alice` (from the user
   name), and run it, enabled at boot. From the peer, `radtest` with the
   right password must be accepted (with PAP and with MS-CHAP), and with a
   wrong one rejected. Open the firewall for RADIUS if it's running.
2. Capture the RADIUS traffic on `le-host` with `tshark` while you send an
   accepted and a rejected request from the peer, into
   `/root/radius.pcapng`, and read it with display filters and
   statistics.
3. Play a rogue router: advertise the prefix `fd00:bad:30::/64` on
   `le-host` with `radvd`. In the peer, see the new address and default
   route, and find the MAC address the advertisements come from with
   `tcpdump`; write it to `/root/lab-answers/3`. Then stop the rogue router
   so that the peer drops the route, and turn forwarding on `le-host` off
   again.
4. Find the rogue DHCP server from this VM by asking on `le-host`
   (`nmap`'s `broadcast-dhcp-discover` script), and write the router
   address it offers to `/root/lab-answers/4`.

## Hints

- RHEL family: `/etc/raddb`, service `radiusd`; run
  `/etc/raddb/certs/bootstrap` (in that directory) once, or the EAP module
  won't load. Ubuntu: `/etc/freeradius/3.0`, service `freeradius`. A
  `client NAME { ipaddr = ...; secret = ... }` block in `clients.conf`;
  `mods-config/files/authorize`: `alice Cleartext-Password := "..."`, then
  an indented `Reply-Message := "Hello, %{User-Name}"`. `radiusd -XC` or
  `freeradius -XC`. In the peer, `radtest [-t mschap] USER PASS 10.99.0.1
  0 SECRET 0 10.99.0.2`: the last two are a PPP hint and the client's own
  address, which radtest otherwise looks up by host name, and the peer
  has no DNS.
- `tshark -i le-host -f "udp port 1812" -a duration:20 -w FILE` in the
  background; `tshark -r FILE -Y 'radius.code == 3'`, `-q -z io,phs`,
  `-q -z conv,udp`. Code 1 is Access-Request, 2 Access-Accept, 3
  Access-Reject.
- `/etc/radvd.conf`: `interface le-host { AdvSendAdvert on; ... prefix
  fd00:bad:30::/64 { }; };`; `sysctl -w net.ipv6.conf.le-host.forwarding=1`.
  In the peer: `ip -6 addr`, `ip -6 route`, `tcpdump -i le-peer -nn -e
  'icmp6 and ip6[40] == 134'`.
- `nmap --script broadcast-dhcp-discover -e le-host`.
