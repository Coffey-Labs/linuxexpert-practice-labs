if command -v virsh >/dev/null; then
	export LIBVIRT_DEFAULT_URI=qemu:///system
	for vm in web1 web2; do
		virsh dominfo "$vm" >/dev/null 2>&1 || continue
		virsh destroy "$vm" >/dev/null 2>&1
		virsh undefine "$vm" --remove-all-storage --snapshots-metadata >/dev/null 2>&1 ||
			virsh undefine "$vm" --snapshots-metadata >/dev/null 2>&1
	done
	rm -f /var/lib/libvirt/images/web1* /var/lib/libvirt/images/web2* /var/lib/libvirt/images/cirros*
fi
rm -rf /var/lib/le-lab/images
true
