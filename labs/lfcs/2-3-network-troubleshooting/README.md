# LFCS 2.3: Network troubleshooting

Finding a wrong gateway, a wrong DNS server and a service listening on the
wrong address, capturing DNS traffic, and finding which process owns a
port.

## Before you start

The peer, a second machine at `10.99.0.2`, is the one to fix in tasks 1
and 2; this VM, `10.99.0.1`, is its gateway. Get a shell there with
`sudo ip netns exec lepeer bash`. The peer has no route to the internet:
from it, `198.51.100.9` stands in for an internet address such as
`9.9.9.9`, and `198.51.100.53` is the network's DNS server, both beyond
its gateway. The peer reads its network settings at boot from
`/etc/netns/lepeer/network` (`ip -batch` commands) and
`/etc/netns/lepeer/resolv.conf`, so fix those as well as the running
system. The lab has also set up a few things on this VM.

## Tasks

1. The peer can't reach `198.51.100.9`. Find out why from the symptoms
   alone, and fix it.
2. On the peer, show that addresses work but names don't, find out why,
   and fix it, so that `getent hosts example.org` works there.
3. The VM's web server (unit `le-lab-web`) can't be reached from the peer
   at `http://10.99.0.1/`. Show from the peer why it can't connect, and fix
   it.
4. Capture the DNS queries the VM sends while you run
   `getent hosts example.org`, save them to `/root/lab-answers/4`, and read
   the file back. On Ubuntu, run `sudo resolvectl flush-caches` first, or
   the answer may come from the cache.
5. Find which process is listening on UDP port 8125, and on which
   addresses. Write its name and the addresses to `/root/lab-answers/5`.

## Hints

- Work up the layers: `ip -br addr`, `ip route`, `ip neigh`, `ping`,
  `ip route get`.
- `getent hosts` versus `dig @198.51.100.53` (or `ping` by address).
- `ss -tlnp` on the VM, `curl -v` from the peer; `systemctl cat` and
  `systemctl edit` for the unit.
- `tcpdump -n -i any port 53 -w FILE`, then `tcpdump -n -r FILE`. tcpdump
  may switch to its own user before it writes the file: add `-Z root`, or
  write to `/tmp` and copy it.
- `ss -ulnp`.
