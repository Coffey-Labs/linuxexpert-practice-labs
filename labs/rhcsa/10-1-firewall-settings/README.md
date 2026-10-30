# RHCSA 10.1: Firewall settings

A rich rule that allows SSH from one network only, port forwarding, and
sending a network's traffic to another zone.

## Before you start

Do this lab at the VM's console, or keep a console open: task 1 changes
who may reach SSH, and a mistake can lock you out.

The lab installs and starts firewalld if it isn't running, and notes its
configuration so reset can put it back. It installs and starts `httpd`
with a test page on port 80, and adds a second machine, `peer`
(`10.99.0.2`), on the lab network `10.99.0.0/24` (this VM is `10.99.0.1`
there), to test from. Get a shell there with
`sudo ip netns exec lepeer bash`. Make every change persistent.

## Tasks

1. Allow SSH only from the network your SSH client is on (such as
   `10.0.2.0/24` for a QEMU user-mode network), with a rich rule, and take
   the `ssh` service out of the zone. You can still log in from inside
   that network; the peer can't reach SSH any more.
2. Forward TCP port 8080 to port 80 on this host, so that from the peer
   `curl http://10.99.0.1:8080/` reaches httpd.
3. Send all traffic from `192.168.50.0/24` to the `internal` zone.

## Hints

- `ss -tn state established '( sport = :22 )'` shows where your SSH
  client connects from. Add the rule before you remove `ssh`:
  `firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source
  address=NETWORK service name=ssh accept'`, `--remove-service=ssh`,
  `--reload`, `--list-rich-rules`.
- `--add-forward-port=port=8080:proto=tcp:toport=80`,
  `--list-forward-ports`; `sudo ip netns exec lepeer curl
  http://10.99.0.1:8080/`.
- `--zone=internal --add-source=`, `--get-active-zones`.
