# RHCSA 8.3: Network connections at boot

Making a static profile come up at boot, and turning that off and on.

## Before you start

The lab gives this VM a spare network interface, `eth1`, cabled to a small
lab network, `192.168.50.0/24`, where a machine answers at `192.168.50.1`.
It comes back at every boot. It also adds a static profile for it, as in
chapter 8.1: `eth1-static`, with `192.168.50.10/24`, which doesn't come up
at boot and isn't up now. Your SSH connection doesn't use `eth1`, so leave
the main interface alone.

Task 2 ends where task 1 does, so the lab runs a small service,
`le-lab-watch`, that notes the profile's state (and every boot) for the
check.

## Tasks

1. Make `eth1-static` come up automatically at boot. After a reboot,
   `nmcli device` shows `eth1` connected with it, and `ip addr` shows its
   address.
2. Turn autoconnect off for `eth1-static` and reboot: `nmcli -f
   NAME,AUTOCONNECT,DEVICE connection show` shows it with `no` and no
   device. Then turn it back on and bring it up.

## Hints

- `nmcli connection modify eth1-static connection.autoconnect yes`,
  `nmcli connection up`.
- `nmcli device`, `ip -br addr show eth1`, `nmcli -f
  NAME,AUTOCONNECT,DEVICE connection show`.
