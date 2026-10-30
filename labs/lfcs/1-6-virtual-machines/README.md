# LFCS 1.6: Virtual machines

Installing libvirt, creating a VM from a cloud image, autostart, more
memory and a second disk, snapshots, and deleting a VM.

## Before you start

The VM you run this lab on needs **nested virtualization** (the CPU flag
`vmx` or `svm` inside it) and about 6 GiB of memory, plus internet access.
The lab downloads a small cloud image, CirrOS, to
`/var/lib/le-lab/images/cirros.img`; it needs no login for these tasks.
libvirt isn't installed: that's part of task 1.

## Tasks

1. Install libvirt and create a VM named `web1` with 1 GiB of memory from
   the cloud image. `virsh list --all` shows `web1` running and
   `virsh domifaddr web1` shows an address (give it a minute to boot).
2. Make `web1` start whenever the host boots.
3. Give `web1` 2 GiB of memory and a second 5 GiB disk that stay after it's
   restarted. After `virsh shutdown` and `virsh start`, `virsh dominfo`
   shows 2097152 KiB and `virsh domblklist web1` shows two disks. CirrOS
   may ignore `virsh shutdown` while it's still booting; `virsh destroy`
   powers it off.
4. Snapshot `web1`, create a file inside the guest, and revert. Keep the
   snapshot. Check the revert yourself: the file is gone (log in on
   `virsh console web1` as user `cirros`, password `gocubsgo`).
5. Create a second VM, `web2`, from the same image, and take a snapshot of
   it. Write the full paths of `web2`'s disk files to
   `/root/lab-answers/5`, one per line. Then delete `web2` and its disks:
   `virsh destroy web2`, delete its snapshots (`virsh snapshot-delete`, or
   add `--snapshots-metadata`), then
   `virsh undefine web2 --remove-all-storage`.

## Hints

- `qemu-kvm libvirt virt-install` on RHEL relatives;
  `qemu-system-x86 libvirt-daemon-system virtinst` on Ubuntu. If `virsh
  list` can't connect on a RHEL relative, start the `virt*d` sockets (the
  chapter has the loop).
- `qemu-img create -f qcow2 -F qcow2 -b BACKING NEW.qcow2`,
  `virt-install --import`, `virt-install --osinfo list`.
- `virsh net-start default`, `virsh net-autostart default`.
- `virsh autostart`, `virsh dominfo`.
- `virsh setmaxmem` and `virsh setmem` with `--config`; `virsh attach-disk
  --persistent`.
- `virsh snapshot-create-as`, `virsh snapshot-list`, `virsh snapshot-revert`.
- `virsh domblklist`, `virsh undefine --remove-all-storage`.
