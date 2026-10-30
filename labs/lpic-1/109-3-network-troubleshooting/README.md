# LPIC-1 109.3: Basic network troubleshooting

Which process holds a port, a test connection with netcat through the
firewall, and a fault found by working through the layers.

## Before you start

The peer, at `10.99.0.2` (name `peer`), stands in for another VM. It sits
on this VM's second network, `10.99.0.0/24`, where this VM is `10.99.0.1`
on interface `le-host`. Get a shell there with
`sudo ip netns exec lepeer bash`. The lab has broken the link to the peer
in one place, for task 3. Your own connection to the VM isn't touched.

## Tasks

1. Find the process listening on port 22 with `sudo ss -tlnp`, and write
   its name to `/root/lab-answers/1`. Then install `net-tools` and compare
   with `netstat -tlnp`.
2. Install netcat if needed, listen on TCP port 9000 on this VM, and connect
   from the peer (`nc 10.99.0.1 9000`). Open the port in the firewall if one
   is running. Type in both directions. Then check the port from the peer
   with `nc -zv`, and leave a listener running on 9000 for the check
   (`nc -lk 9000`).
3. This VM can't reach the peer: `ping 10.99.0.2` fails. Work through the
   troubleshooting order (link, address, route, then the far end) to find
   the fault, fix it, and write the name of the interface at fault to
   `/root/lab-answers/3`.

## Hints

- `ss -tlnp 'sport = :22'`; on Ubuntu, `systemd` holds the port for
  `ssh.socket`. `netstat` is in `net-tools`.
- `nc` is in `nmap-ncat` on the RHEL family and `netcat-openbsd` on Ubuntu.
  `firewall-cmd --add-port=9000/tcp` (add `--permanent` to keep it), or
  `ufw allow 9000/tcp`. Run `nc -lk 9000 &` in the background, or under
  `setsid`.
- `ip -br link`, `ip -br addr`, `ip route`, `ping`.
