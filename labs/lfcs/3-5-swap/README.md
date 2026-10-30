# LFCS 3.5: Swap space

Swap files and swap partitions, priorities, removing swap, and swappiness.

## Before you start

The lab adds an empty 1 GiB spare disk, `/dev/loop40` (partitions show up
as `/dev/loop40p1` and so on). It comes back at every boot before swap is
turned on, so `/etc/fstab` lines for it keep working. The lab also adds a
128 MiB swap file, `/var/swap.old`, in use and listed in `/etc/fstab`.

## Tasks

1. Add a 1 GiB swap file at `/swapfile` that's used after every reboot.
2. Add a 512 MiB swap partition on `/dev/loop40` with priority 10, and give
   the swap file `/swapfile` priority 5, both after every reboot too.
3. Turn off the swap file `/var/swap.old` without rebooting, and remove it
   for good.
4. Set swappiness to 10 persistently.

## Hints

- `dd` or `fallocate`, `chmod 600`, `mkswap`, `swapon`; `swapon --show`,
  `free -h`.
- `fdisk`, `gdisk` or `parted` (type Linux swap); `mkswap`, `blkid`. In
  `/etc/fstab` swap has mount point `none`, type `swap`, and `pri=` among
  the options; `swapon -a`.
- `swapoff`, then clean up `/etc/fstab`.
- `sysctl vm.swappiness`; a file in `/etc/sysctl.d/`, `sysctl --system`.
