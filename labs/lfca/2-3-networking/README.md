# LFCA 2.3: Networking

Addresses and routes, a subnet worked out by hand, listening ports, DNS
lookups, SSH keys, and a firewall that allows only SSH.

## Before you start

Work as root (`sudo -i`), so `~` is `/root`. Answers go in
`/root/lab-answers/<task>`. The VM needs internet access for task 4.

The lab runs a web server on port 8080 and creates user `alice` (password
`Lab-Pass-1`). The peer, at `10.99.0.2` (name `peer`), stands in for a
computer outside the VM; this VM is `10.99.0.1` there. Get a shell there
with `sudo ip netns exec lepeer bash`. The lab notes the firewall's
settings, and reset puts them back. Keep a console open for task 6: a
firewall mistake can cut off SSH.

## Tasks

1. Find the VM's IPv4 address with its prefix, its default gateway and its
   DNS servers. Write the address with its prefix (like `192.0.2.10/24`)
   and the gateway to `/root/lab-answers/1`, one per line.
2. Work out the network address, broadcast address and usable range of
   `10.20.30.77/26`. Write them to `/root/lab-answers/2`, one per line:
   network, broadcast, first usable, last usable. Check your answer with
   `ipcalc` if it's installed.
3. List the listening ports with `ss -tulpn` and say which service each
   belongs to. Write the name of the program listening on TCP port 8080 to
   `/root/lab-answers/3`.
4. Look up the `A`, `AAAA` and `MX` records of a domain you know with `dig`
   (in `bind9-dnsutils` on Ubuntu, `bind-utils` on the RHEL family). Write
   the domain to `/root/lab-answers/4`.
5. Set up SSH key login from root to `alice` on this VM: make a key pair
   for root, so that `ssh alice@localhost` logs in without a password.
6. Turn on the VM's firewall (firewalld on the RHEL family, ufw on Ubuntu),
   allow only SSH, and check that the web server on port 8080 can no longer
   be reached from the peer, while SSH still can.

## Hints

- `ip addr`, `ip route`, `/etc/resolv.conf` or `resolvectl status`.
- A /26 has 64 addresses; the network address is a multiple of 64.
  `ipcalc 10.20.30.77/26`.
- `ss -tulpn`, the `users:(("NAME",...))` column.
- `dig example.org A`, `dig example.org AAAA +short`, `dig example.org MX`.
- `ssh-keygen`, `ssh-copy-id alice@localhost`, then
  `ssh alice@localhost`.
- `dnf install firewalld`, `systemctl enable --now firewalld`,
  `firewall-cmd --list-all`, `--remove-service`, `--remove-port`,
  `--permanent`, `--reload`. `ufw allow OpenSSH`, `ufw enable`,
  `ufw status`. From the peer: `curl --max-time 5 http://10.99.0.1:8080/`.
