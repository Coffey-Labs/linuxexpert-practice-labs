# Linux+ 1.4.2: Network tools

Mapping the VM's network, following a lookup and a connection, capturing
DNS traffic, and testing a port and throughput between two machines.

## Before you start

The peer, at `10.99.0.2` (name `peer`), stands in for the other VM. It sits
on this VM's second network, `10.99.0.0/24`, where this VM is `10.99.0.1`.
It shares this VM's files and installed programs, but has its own network
stack: get a shell there with `sudo ip netns exec lepeer bash`. Tasks 1 and
2 ask for findings: write them to the files in `/root/lab-answers/` that
they name. Task 2 needs internet access. Reset closes the ports again and
removes `iperf3` and `nc` if they weren't installed before the lab.

## Tasks

1. Map this VM's network: addresses, routes, neighbors, listening ports.
   Write the address of the default gateway to `/root/lab-answers/1`.
2. Look up `www.kernel.org`, trace the path to it, and fetch the headers of
   `https://www.kernel.org`. Write the first line of the headers (the
   status line, such as `HTTP/1.1 301 Moved Permanently`) to
   `/root/lab-answers/2`.
3. Capture your own DNS traffic with `tcpdump` while you look up a name.
   Not graded.
4. Test a port and the throughput between this VM (VM A) and the peer
   (VM B). Install `iperf3` and `nc`, and if a firewall is running here,
   open ports 9000/tcp and 5201/tcp until the next reboot. Run `nc -l 9000`
   here and `nc -zv 10.99.0.1 9000` in the peer, then `iperf3 -s` here and
   `iperf3 -c 10.99.0.1` in the peer.

## Hints

- `ip -br a`, `ip r`, `ip neigh`, `ss -tulnp`, `hostname -I`.
- On the RHEL family, `dig` is in `bind-utils`, and `nc` in `nmap-ncat`.
  `dig +short`, `tracepath -n`, `curl -sI URL | head -1`.
- `tcpdump -i any -nn port 53` in one terminal, `dig example.org` in
  another; Ctrl+c stops tcpdump.
- `firewall-cmd --add-port=9000/tcp --add-port=5201/tcp` (without
  `--permanent`); with ufw, `ufw allow 9000/tcp`.
