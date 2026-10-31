# Ubuntu Desktop 3.4: Proprietary GPU and Wi-Fi drivers

Finding out whether a machine needs a proprietary driver, where those
drivers live in the archive, the Secure Boot state, and which kernel
driver each network device uses. Nothing gets installed: the lab runs
on a VM, which has no hardware that needs these drivers.

## Before you start

The lab installs `ubuntu-drivers-common` (the `ubuntu-drivers` command)
if it's missing; reset removes it again. Write your answers to the files
in `/root/lab-answers/`, one item per line.

## Tasks

1. Find out whether this machine needs any proprietary driver. Write
   `yes` or `no` to `/root/lab-answers/1`.
2. Find which component the NVIDIA 580 driver (`nvidia-driver-580`) and
   the Broadcom STA Wi-Fi driver (`bcmwl-kernel-source`) are in, and what
   Secure Boot state this machine is in. Write the two components on
   lines 1 and 2 of `/root/lab-answers/2`, and on line 3 `enabled`,
   `disabled` or `no EFI`.
3. For each network device, find the kernel driver in use. Write the
   drivers to `/root/lab-answers/3`, one line per network device.

## Hints

- `ubuntu-drivers devices` prints nothing when every device works with
  open source drivers.
- `apt-cache show PACKAGE | grep -m1 Section`; `mokutil --sb-state`.
- `lspci -k` shows a `Kernel driver in use:` line under each network
  controller.
