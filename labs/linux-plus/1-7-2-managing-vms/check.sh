export LIBVIRT_DEFAULT_URI=qemu:///system
IMG=/var/lib/libvirt/images/lab1.qcow2
xml() { virsh dumpxml --inactive lab1 2>/dev/null; }

task 1 "lab1 imported from lab1.qcow2 (10 GiB), 1 GiB, VirtIO disk and network"
need "virsh list --all works" 'virsh list --all'
need "VM lab1 exists" 'virsh dominfo lab1'
need "lab1's disk is $IMG" 'virsh domblklist lab1 --inactive --details | awk "\$2 == \"disk\" {print \$4}" | grep -qxF "$IMG"'
need "$IMG is 10 GiB" 'qemu-img info -U --output=json "$IMG" | grep -Eq "\"virtual-size\": 10737418240,"'
need "the disk is on the VirtIO bus" 'xml | grep -Eq "<target dev=.vd[a-z]. bus=.virtio./>"'
need "the network card is VirtIO, on the default network" 'xml | grep -q "<source network=.default." && xml | grep -q "<model type=.virtio./>"'
need "lab1 has 1 GiB of memory" 'xml | grep -Eq "<memory unit=.KiB.>1048576</memory>"'
need "lab1 has one vCPU" 'xml | grep -Eq "<vcpu[^>]*>1</vcpu>"'

task 2 "Suspend, resume, setmem and shut down" self

task 3 "A snapshot clean of lab1, reverted to"
need "lab1 has a snapshot named clean" 'virsh snapshot-list lab1 --name | grep -qx clean'
need "clean is lab1's current snapshot (reverted)" '[ "$(virsh snapshot-current lab1 --name 2>/dev/null)" = clean ]'
