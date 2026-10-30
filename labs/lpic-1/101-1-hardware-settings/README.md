# LPIC-1 101.1: Hardware settings

Finding the driver behind a device, loading and unloading kernel modules,
and blacklisting a module so it doesn't load at boot.

This lab runs on the RHEL family only: the Ubuntu cloud kernel doesn't
include the `pcspkr` module, and Ubuntu blacklists it already.

## Before you start

The lab installs `pciutils` (for `lspci`) if it's missing, and notes the
current boot so it can tell that you rebooted. Write answers to the files
in `/root/lab-answers/`.

## Tasks

1. With `lspci -k`, find the kernel driver in use for the VM's Ethernet
   controller, and write its name to `/root/lab-answers/1`.
2. Unload and reload a module that nothing is using, then check `dmesg`
   for the messages. `loop` works if `lsmod` lists it with nothing in
   "Used by". Check it yourself: the module is back in `lsmod`.
3. Add `blacklist pcspkr` to a file in `/etc/modprobe.d/`, reboot, and
   confirm with `lsmod` that it didn't load. Then load it by hand with
   `modprobe`.

## Hints

- `lspci -k` prints "Kernel driver in use" under each device.
- `lsmod`, `modprobe -r`, `modprobe`, `dmesg | tail`.
- `modprobe --showconfig | grep pcspkr`; `lsmod | grep pcspkr`.
