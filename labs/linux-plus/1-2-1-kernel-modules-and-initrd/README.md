# Linux+ 1.2.1: Kernel modules and the initrd

Looking at modules, loading one with an option, loading it at every boot,
and finding the root disk's driver in the initrd.

## Before you start

The lab unloads the `dummy` module, a harmless one that makes network
devices. Reboot when task 3 says so; the check looks at the running system.

## Tasks

1. Find the license of the `xfs` module and write it to
   `/root/lab-answers/1`.
2. Load `dummy` with the option `numdummies=3`, check that it made three
   devices, and unload it again. Not graded: `ip -br link show type dummy |
   wc -l` should print `3` before you unload it.
3. Make `dummy` load at every boot with the option `numdummies=1`, then
   reboot. After the reboot, `ip -br link show type dummy` shows exactly one
   device. Keep your files until you've run `le-lab check`; reset removes
   them.
4. Look inside your initrd, and find the driver for your root disk
   (`virtio_blk`, `nvme` or `ahci`, for example). Write its name to
   `/root/lab-answers/4`.

## Hints

- `lsmod`, `modinfo xfs`, `modinfo -F license`.
- `modprobe dummy numdummies=3`, `modprobe -r dummy`.
- `/etc/modules-load.d/` for loading, `/etc/modprobe.d/` for options. Files
  in every `modprobe.d` directory are read in name order and the last
  setting wins; `modprobe --show-depends dummy` shows what modprobe will
  pass.
- `lsinitrd` on the RHEL family, `lsinitramfs /boot/initrd.img-$(uname -r)`
  on Ubuntu, which builds `virtio_blk` into the kernel:
  `grep virtio_blk /lib/modules/$(uname -r)/modules.builtin`. `lsblk` shows
  the root disk.
