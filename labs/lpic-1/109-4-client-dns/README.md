# LPIC-1 109.4: Client-side DNS

Who writes `/etc/resolv.conf`, `/etc/hosts` against DNS, and a search
domain.

## Before you start

The lab saves the network configuration (NetworkManager's profiles on the
RHEL family; netplan and systemd-resolved's settings on Ubuntu) so reset
can put it back. Task 2 needs the VM to resolve names on the internet.

## Tasks

1. Read `/etc/nsswitch.conf`, and check whether `/etc/resolv.conf` is a link
   with `ls -l`. Which program writes it? Write its name to
   `/root/lab-answers/1`.
2. Add `example.org` as a search domain (through NetworkManager or
   systemd-resolved, since `resolv.conf` is generated), persistently, and
   look up the short name `www`: `getent hosts www` must find
   `www.example.org`.
3. Add `192.168.1.250 fake.example.org` to `/etc/hosts`. Compare
   `getent hosts fake.example.org` with `dig fake.example.org`, and work out
   why they differ. Write the address `getent` prints to
   `/root/lab-answers/3`, then remove the line from `/etc/hosts`.

## Hints

- `ls -l /etc/resolv.conf`; the comment at the top of the file.
- `nmcli connection modify ... ipv4.dns-search`, then
  `nmcli device reapply`; or `Domains=` in a drop-in in
  `/etc/systemd/resolved.conf.d/`, or `search:` under `nameservers:` in
  netplan. `resolvectl status` and `cat /etc/resolv.conf` show it.
- `dig` is in `bind-utils` on the RHEL family and `bind9-dnsutils` on
  Ubuntu. Which of the two reads `/etc/hosts`?
