# Linux+ 2.4.3: DNS, time and DHCP services

Which service keeps the clock in sync, a caching DNS server that another
machine can use, and reading a DHCP lease from the client side.

## Before you start

The lab sets up a second machine, `peer` (10.99.0.2), linked to this VM's
address 10.99.0.1. It stands in for the chapter's other VM. On RHEL
relatives the lab installs `bind-utils` for `dig`. Write answers to the
files in `/root/lab-answers/`.

## Tasks

1. Find out which service keeps this VM's clock in sync, and write its
   name (`chronyd` or `systemd-timesyncd`) to `/root/lab-answers/1`.
2. RHEL relatives: build a caching DNS server with Unbound that listens on
   all addresses and answers clients from 10.0.0.0/8 and 192.168.0.0/16,
   and that starts at boot. Open the firewall for DNS if it's running.
   From the peer, `dig @10.99.0.1` should get answers.
3. Find the address of the DHCP server that gave this VM its address, and
   write it to `/root/lab-answers/3`.

## Hints

- `chronyc sources -v`, `chronyc tracking`, `timedatectl`,
  `timedatectl timesync-status`, `systemctl status`.
- A file in `/etc/unbound/conf.d/` with `interface:` and
  `access-control:` lines, `unbound-checkconf`, `systemctl enable --now`,
  `firewall-cmd --add-service=dns` (and `--permanent`);
  `ip netns exec lepeer dig @10.99.0.1 www.kernel.org`.
- `nmcli -f DHCP4 device show DEVICE` (`dhcp_server_identifier`);
  `networkctl status`, `journalctl -u systemd-networkd`,
  `/run/systemd/netif/leases/`.
