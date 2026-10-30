if command -v virsh >/dev/null; then
	export LIBVIRT_DEFAULT_URI=qemu:///system
	if virsh dominfo lab1 >/dev/null 2>&1; then
		virsh destroy lab1 >/dev/null 2>&1
		for s in $(virsh snapshot-list lab1 --name 2>/dev/null); do virsh snapshot-delete lab1 "$s" >/dev/null 2>&1; done
		virsh undefine lab1 --remove-all-storage --snapshots-metadata --nvram >/dev/null 2>&1 ||
			virsh undefine lab1 --snapshots-metadata >/dev/null 2>&1
	fi
	rm -f /var/lib/libvirt/images/lab1.qcow2
fi
rm -rf /var/lib/le-lab/images
true
