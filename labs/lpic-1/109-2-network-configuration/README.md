# LPIC-1 109.2: Persistent network configuration

NetworkManager's devices, profiles and their files, a static address that
lasts, the host name, and `/etc/hosts`.

## Before you start

The peer, at `10.99.0.2` (name `peer`), stands in for another machine.

On the RHEL family, the lab also adds a second network for task 2, so your
own connection to the VM is never touched: interface `le-lan`, with the
NetworkManager profile `lab-net`, which gets an address by DHCP from a
server at `10.98.0.1` on the far side. Tasks 1 and 2 use NetworkManager and
are graded on the RHEL family only; Ubuntu servers use netplan instead.

## Tasks

1. RHEL family: read `nmcli device` and `nmcli connection show`, and find the
   file of the main interface's active connection with
   `nmcli -f NAME,FILENAME connection show`. Read it with `sudo`, and write
   its path to `/root/lab-answers/1`.
2. RHEL family: give profile `lab-net` the static address `10.98.0.10/24`
   with `nmcli connection modify`, bring the connection up, check with
   `ip addr` and `ip route`, and reboot to show it lasts. (The chapter then
   returns it to DHCP: do that after you've run the check.)
3. Change the host name to `lab2.example.net` with `hostnamectl`, and check
   `/etc/hostname`, the prompt in a new shell, and `hostname -f`.
4. Add the name `files.lab.example` for the peer's address, `10.99.0.2`, to
   `/etc/hosts`, and `ping` it by name.

## Hints

- `nmcli -f NAME,DEVICE,FILENAME connection show --active`.
- `nmcli connection modify lab-net ipv4.method manual ipv4.addresses ...`,
  then `nmcli connection up lab-net`; `ip -br addr show le-lan`.
- `hostnamectl set-hostname`, `hostnamectl status`.
- One line in `/etc/hosts`: the address, then the names; `getent hosts`.
