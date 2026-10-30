# Linux+ 1.7.1: KVM, QEMU and virtual disks

Getting a host ready for KVM, and working with disk images: qcow2 and raw,
resizing, converting, and a backing file.

## Before you start

Task 1 is best done on a VM with **nested virtualization** (the CPU flag
`vmx` or `svm` inside it), but nothing here runs a VM, so the lab works
without it too: `virt-host-validate` then reports what's missing. The
images go in `/tmp`, which Ubuntu empties at boot, so do task 2 without a
reboot. Task 3 asks for a finding: write it to `/root/lab-answers/3`.
Reset removes the packages task 1 installs, if they weren't there before.

## Tasks

1. Check the host for KVM support, install QEMU, `qemu-img`, libvirt and
   `virt-install`, and run `virt-host-validate qemu`.
2. Create a 5 GiB qcow2 image `/tmp/a.qcow2` and grow it by 1 GiB. Convert
   it to a raw image, `/tmp/a.raw`, and compare the space each really
   uses. Then create `/tmp/b.qcow2`, a qcow2 image with `/tmp/a.qcow2` as
   its backing file, and look at the backing chain.
3. Check whether this VM uses VirtIO devices. Write the driver of its main
   network interface, as `ethtool -i` reports it, to `/root/lab-answers/3`.

## Hints

- `grep -cE 'vmx|svm' /proc/cpuinfo`, `lsmod | grep kvm`, `ls -l /dev/kvm`.
- RHEL family: `qemu-kvm qemu-img libvirt virt-install`. Ubuntu:
  `qemu-system-x86 qemu-utils libvirt-daemon-system virtinst`.
- `qemu-img create -f qcow2`, `qemu-img info`, `qemu-img resize +1G`,
  `qemu-img convert -f qcow2 -O raw`, `ls -ls`,
  `qemu-img create -f qcow2 -F qcow2 -b BACKING NEW`,
  `qemu-img info --backing-chain`.
- `lspci | grep -i virtio`; `ip route` shows the main interface.
