# Linux+ 1.2.2: Finding out about hardware

An inventory of the VM's hardware, the kernel's messages as a device
appears, and PCI devices that no driver has claimed.

## Before you start

The lab sets nothing up. Tasks 1 and 3 ask for findings: write them to the
files in `/root/lab-answers/` that the tasks name.

## Tasks

1. Build a quick inventory of this VM with `lscpu`, `lsmem`, `lspci`,
   `lsusb`, `lshw` and `dmidecode`. The "hardware" is the hypervisor's: write
   the system manufacturer that `dmidecode` reports (such as `QEMU`) to
   `/root/lab-answers/1`.
2. Run `dmesg -w` in one terminal, then attach a USB device or a new
   virtual disk to the VM, and watch the kernel's messages. Not graded.
3. Find every PCI device without a driver, and write their slot addresses
   (such as `00:00.0`), one per line, to `/root/lab-answers/3`. If there are
   none, write `none`.

## Hints

- Minimal RHEL-family installs need `pciutils` and `usbutils` for `lspci`
  and `lsusb`.
- `dmidecode -t system`, or `dmidecode -s system-manufacturer`.
- A device that a driver has claimed has a `driver` link in sysfs:
  `for d in /sys/bus/pci/devices/*; do [ -e "$d/driver" ] || lspci -s "${d##*/}"; done`
