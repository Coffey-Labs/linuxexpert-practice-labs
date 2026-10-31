# Ubuntu Desktop 1.1: Network connections

Making a NetworkManager profile with a fixed address, switching it to
DHCP while keeping a DNS server, and seeing where Ubuntu stores it. The
lab works on a spare interface, never on the one you're connected over.
The chapter's Wi-Fi task needs Wi-Fi hardware and isn't part of the lab.

## Before you start

The lab adds a spare wired interface `lab0` (a dummy interface that
comes back at every boot). If NetworkManager isn't installed, as on
Ubuntu Server, the lab installs it; it leaves the interfaces it already
finds alone, and reset removes it again. Don't activate the profile.

## Tasks

1. Create a profile `office` for interface `lab0` with the fixed address
   10.10.10.50/24, gateway 10.10.10.1 and DNS 10.10.10.1, without
   activating it.
2. Make the profile use DHCP for its address but keep the DNS server
   10.10.10.1. Task 1 stays passed once you've done this.

When `le-lab check` passes, remove the profile as the chapter shows, or
leave that to `le-lab reset`.

## Hints

- `nmcli connection add type ethernet ifname lab0 con-name office
  ipv4.method manual ipv4.addresses ... ipv4.gateway ... ipv4.dns ...
  connection.autoconnect no`. `nmcli -g ipv4.method,ipv4.addresses
  connection show office` prints `manual` and `10.10.10.50/24`, and `sudo
  ls /etc/netplan/` shows a new `90-NM-` file.
- `nmcli connection modify office ipv4.method auto`, clearing the old
  address with `ipv4.addresses "" ipv4.gateway ""`, and
  `ipv4.ignore-auto-dns yes` so DHCP's DNS servers aren't used.
- `nmcli connection delete office`.
