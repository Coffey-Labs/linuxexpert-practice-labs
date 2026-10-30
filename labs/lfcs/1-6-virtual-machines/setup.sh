if ! grep -qE 'vmx|svm' /proc/cpuinfo; then
	warn "This VM has no nested virtualization (no vmx or svm CPU flag); VMs inside it won't run."
fi
mkdir -p /var/lib/le-lab/images
if [ ! -s /var/lib/le-lab/images/cirros.img ]; then
	say "${C_DIM}Downloading the CirrOS cloud image...${C_0}"
	curl -fsSL -o /var/lib/le-lab/images/cirros.img.part \
		https://download.cirros-cloud.net/0.6.3/cirros-0.6.3-x86_64-disk.img
	mv /var/lib/le-lab/images/cirros.img.part /var/lib/le-lab/images/cirros.img
fi
# web1 and web2 shouldn't exist yet.
if command -v virsh >/dev/null; then
	for vm in web1 web2; do
		if virsh dominfo "$vm" >/dev/null 2>&1; then
			die "a VM named $vm already exists; delete it first, or run le-lab reset"
		fi
	done
fi
true
