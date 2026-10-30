# LPIC-1 102.6: Linux as a virtualization guest

Recognizing a virtual machine from the inside, and fixing what a clone
copies from its template.

## Before you start

The lab treats this VM as a fresh clone: it notes its machine ID, SSH host
keys and hostname as the template's, so task 2 can tell whether you
changed them. Reset puts the hostname back, but keeps the new machine ID
and host keys. Write answers to the files in `/root/lab-answers/`.

## Tasks

1. Run `systemd-detect-virt` and `lscpu` in the VM, and `lsmod | grep
   virtio`. Write the hypervisor `systemd-detect-virt` reports to
   `/root/lab-answers/1`.
2. A clone comes out with the same `/etc/machine-id`, SSH host keys
   (`ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub`) and `hostname` as
   its template. Fix all three on this VM: a new machine ID, new SSH host
   keys and a new hostname, all still in place after a reboot, with SSH
   still working. (`ip link` would show the same MAC address too; the
   hypervisor sets that one.)

## Hints

- `systemd-detect-virt`, `lscpu | grep -i hypervisor`.
- Empty `/etc/machine-id` (don't delete it), then
  `systemd-machine-id-setup`; or `systemd-firstboot`.
- Remove `/etc/ssh/ssh_host_*`, then `ssh-keygen -A`, and restart sshd
  (`ssh` on Ubuntu). Your SSH client will warn that the host key changed:
  remove the old key with `ssh-keygen -R`.
- `hostnamectl set-hostname`. On a cloud image, cloud-init sets the
  hostname again at every boot unless `preserve_hostname: true` is in a
  file under `/etc/cloud/cloud.cfg.d/`.
