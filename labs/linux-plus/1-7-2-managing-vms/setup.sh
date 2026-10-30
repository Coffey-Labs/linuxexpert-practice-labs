if ! grep -qE 'vmx|svm' /proc/cpuinfo; then
	warn "This VM has no nested virtualization (no vmx or svm CPU flag); VMs inside it won't run."
fi
if command -v virsh && virsh -c qemu:///system dominfo lab1; then
	refuse "a VM named lab1 already exists; delete it first"
fi >/dev/null 2>&1
# The KVM host from chapter 1.7.1.
if is_rhel; then
	pkg_installed libvirt && pkg_installed virt-install && pkg_installed qemu-kvm || pkg_install qemu-kvm qemu-img libvirt virt-install
else
	pkg_installed libvirt-daemon-system && pkg_installed virtinst && pkg_installed qemu-system-x86 ||
		pkg_install qemu-system-x86 qemu-utils libvirt-daemon-system virtinst
fi
mkdir -p /var/lib/le-lab/images
if [ ! -s /var/lib/le-lab/images/cirros.img ]; then
	say "${C_DIM}Downloading the CirrOS cloud image...${C_0}"
	curl -fsSL -o /var/lib/le-lab/images/cirros.img.part \
		https://download.cirros-cloud.net/0.6.3/cirros-0.6.3-x86_64-disk.img
	mv /var/lib/le-lab/images/cirros.img.part /var/lib/le-lab/images/cirros.img
fi
