grep -qE 'vmx|svm' /proc/cpuinfo || warn "This VM has no nested virtualization (no vmx or svm CPU flag); virt-host-validate will say so."
rm -f /tmp/a.qcow2 /tmp/a.raw /tmp/b.qcow2
# Reset takes out again what task 1 installs, so that the lab starts over.
for p in $(pick "qemu-kvm qemu-img libvirt virt-install" "qemu-system-x86 qemu-utils libvirt-daemon-system virtinst"); do
	pkg_installed "$p" || printf '%s\n' "$p" >>"$LAB_STATE/not-installed"
done
