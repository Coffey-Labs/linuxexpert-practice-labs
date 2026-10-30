export LIBVIRT_DEFAULT_URI=qemu:///system

task 1 "libvirt installed; web1 created from the cloud image and running"
need "virsh list works" 'virsh list --all'
need "VM web1 exists" 'virsh dominfo web1'
need "web1 is running" '[ "$(virsh domstate web1)" = running ]'
need "web1 has an IP address" 'virsh domifaddr web1 | grep -q ipv4 || virsh domifaddr web1 --source arp | grep -q ipv4'

task 2 "web1 starts when the host boots"
need "web1 has autostart on" 'virsh dominfo web1 | grep -Eq "^Autostart:[[:space:]]+enable"'

task 3 "web1 has 2 GiB of memory and a second 5 GiB disk, for good"
need "web1's saved definition has 2 GiB of memory" '
	x=$(virsh dumpxml --inactive web1)
	grep -Eq "<memory unit=.KiB.>2097152</memory>" <<<"$x" && grep -Eq "<currentMemory unit=.KiB.>2097152</currentMemory>" <<<"$x"'
need "web1's saved definition has two disks" '[ "$(virsh domblklist web1 --inactive --details | awk "\$2 == \"disk\"" | wc -l)" -ge 2 ]'
need "one of web1's disks is 5 GiB" '
	virsh domblklist web1 --inactive --details | awk "\$2 == \"disk\" {print \$4}" | while read -r f; do
		qemu-img info -U --output=json "$f" 2>/dev/null | grep -Eq "\"virtual-size\": 5368709120,"  && echo yes
	done | grep -q yes'
need "running web1 has 2 GiB" 'virsh dominfo web1 | grep -Eq "^Used memory:[[:space:]]+2097152 KiB"'
need "running web1 has two disks" '[ "$(virsh domblklist web1 --details | awk "\$2 == \"disk\"" | wc -l)" -ge 2 ]'

task 4 "web1 snapshotted and reverted"
need "web1 has a snapshot" '[ -n "$(virsh snapshot-list web1 --name | grep .)" ]'

task 5 "web2 and its disks deleted"
need "/root/lab-answers/5 lists web2's disk files" 'grep -q "^/" /root/lab-answers/5'
need "VM web2 no longer exists" '! virsh dominfo web2'
need "web2's disk files are gone" '! grep "^/" /root/lab-answers/5 | while read -r f; do [ -e "$f" ] && echo left; done | grep -q left'
need "web1's disks weren't touched" '
	virsh domblklist web1 --inactive --details | awk "\$2 == \"disk\" {print \$4}" | while read -r f; do [ -e "$f" ] || echo missing; done | grep -q missing && exit 1
	true'
