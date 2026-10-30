# Linux+ 1.7.2: Managing virtual machines

Creating a VM from a cloud image with virt-install, suspending, resizing
and shutting it down, and a snapshot to undo a mistake.

## Before you start

The VM you run this lab on needs **nested virtualization** (the CPU flag
`vmx` or `svm` inside it) and about 6 GiB of memory, plus internet access.
The lab installs QEMU, libvirt and virt-install (the KVM host from chapter
1.7.1) and downloads a small cloud image, CirrOS, to
`/var/lib/le-lab/images/cirros.img`. Use it where the chapter downloads a
Rocky Linux or Ubuntu image (or download one of those yourself). Its user
is `cirros`, password `gocubsgo`.

## Tasks

1. Create a VM named `lab1` from the cloud image: copy it to
   `/var/lib/libvirt/images/lab1.qcow2`, grow that to 10 GiB, and import it
   with virt-install, with 1 GiB of memory, one vCPU, a VirtIO disk, a
   VirtIO network card on the `default` network, and a generated root
   password from cloud-init. `virsh list --all` shows it, and
   `virsh domifaddr lab1` shows its address once it has booted.
2. Suspend and resume `lab1`, give it 768 MiB of memory while it runs, then
   shut it down. Not graded.
3. Start `lab1` again, snapshot it as `clean`, break something inside it
   (log in on `virsh console lab1` and run `rm -rf /etc/ssh`; Ctrl+] leaves
   the console), and revert to the snapshot.

When `le-lab check` passes, clean up as the chapter shows (task 4: delete
the snapshot, then destroy and undefine `lab1` with its storage), or leave
it to `le-lab reset`.

## Hints

- On the RHEL family, start the libvirt sockets first:
  `systemctl enable --now virtqemud.socket virtnetworkd.socket virtstoraged.socket`.
- `qemu-img resize`; `virt-install --import --disk PATH,bus=virtio
  --network network=default,model=virtio --os-variant detect=on,require=off
  --cloud-init root-password-generate=on --noautoconsole`.
- `virsh suspend`, `virsh resume`, `virsh setmem lab1 768M --live`,
  `virsh shutdown`, `virsh domstate`; CirrOS may ignore `virsh shutdown`
  while it's still booting, and `virsh destroy` powers it off.
- `virsh snapshot-create-as lab1 clean`, `virsh snapshot-list lab1`,
  `virsh snapshot-revert lab1 clean`.
