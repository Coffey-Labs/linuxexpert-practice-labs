# LPIC-1 109.2: Persistent network configuration

NetworkManager's devices, profiles and their files (netplan's on Ubuntu), a
static address that lasts, the host name, and `/etc/hosts`.

## Before you start

The peer, at `10.99.0.2` (name `peer`), stands in for another machine.

The lab also adds a second network for task 2, so your own connection to
the VM is never touched: interface `le-lan`, with a machine at `10.98.0.1`
on the far side. On the RHEL family it has the NetworkManager profile
`lab-net`, which gets an address by DHCP from that machine. Ubuntu Server
uses netplan with networkd and doesn't install NetworkManager, so there
`le-lan` starts with no address, and you do tasks 1 and 2 with netplan.

## Tasks

1. Find the configuration file of the main interface, and write its path
   to `/root/lab-answers/1`. RHEL family: read `nmcli device` and
   `nmcli connection show`, find the file of the active connection with
   `nmcli -f NAME,FILENAME connection show`, and read it with `sudo`.
   Ubuntu: read the files in `/etc/netplan/` and `networkctl status`, and
   find the netplan file that sets up the main interface.
2. Give `le-lan` the static address `10.98.0.10/24`, check with `ip addr`
   and `ip route`, and reboot to show it lasts. RHEL family: on profile
   `lab-net`, with `nmcli connection modify`, then bring the connection up.
   (The chapter then returns it to DHCP: do that after you've run the
   check.) Ubuntu: in a new netplan file, `/etc/netplan/90-lab.yaml`,
   applied with `netplan try`.
3. Change the host name to `lab2.example.net` with `hostnamectl`, and check
   `/etc/hostname`, the prompt in a new shell, and `hostname -f`.
4. Add the name `files.lab.example` for the peer's address, `10.99.0.2`, to
   `/etc/hosts`, and `ping` it by name.

## Hints

- `nmcli -f NAME,DEVICE,FILENAME connection show --active`. On Ubuntu,
  `ls /etc/netplan`, `networkctl list`, `networkctl status`.
- `nmcli connection modify lab-net ipv4.method manual ipv4.addresses ...`,
  then `nmcli connection up lab-net`; `ip -br addr show le-lan`.
- In netplan, an `ethernets:` entry for `le-lan` with
  `addresses: [10.98.0.10/24]`; `chmod 600` the file; `netplan try` (press
  Enter to keep it).
- `hostnamectl set-hostname`, `hostnamectl status`.
- One line in `/etc/hosts`: the address, then the names; `getent hosts`.
