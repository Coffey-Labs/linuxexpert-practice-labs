IF=$(ip -4 route show default | awk '{for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit }}')
drv=$(basename "$(readlink -f "/sys/class/net/$IF/device/driver" 2>/dev/null)" 2>/dev/null)
command -v ethtool >/dev/null && drv=$(ethtool -i "$IF" 2>/dev/null | awk '$1 == "driver:" {print $2}')
info() { qemu-img info -U --output=json "$1" 2>/dev/null; }
field() { info "$1" | python3 -c 'import json,sys; v = json.load(sys.stdin).get(sys.argv[1]); print("" if v is None else v)' "$2" 2>/dev/null; }

task 1 "QEMU, qemu-img, libvirt and virt-install installed"
need "qemu-img is installed" 'command -v qemu-img'
need "a QEMU system emulator is installed" 'ls /usr/libexec/qemu-kvm /usr/bin/qemu-system-x86_64 2>/dev/null | grep -q .'
need "libvirt is installed (virsh and the QEMU driver)" 'command -v virsh && ls /usr/sbin/virtqemud /usr/sbin/libvirtd 2>/dev/null | grep -q .'
need "virt-install is installed" 'command -v virt-install'
need "virt-host-validate is installed" 'command -v virt-host-validate'

task 2 "a.qcow2 grown to 6 GiB, a.raw converted from it, b.qcow2 backed by it"
need "/tmp/a.qcow2 is a qcow2 image" '[ "$(field /tmp/a.qcow2 format)" = qcow2 ]'
need "/tmp/a.qcow2 is 6 GiB (5 + 1)" '[ "$(field /tmp/a.qcow2 virtual-size)" = 6442450944 ]'
need "/tmp/a.raw is a raw image of 6 GiB" '[ "$(field /tmp/a.raw format)" = raw ] && [ "$(stat -c %s /tmp/a.raw)" = 6442450944 ]'
need "/tmp/b.qcow2 is a qcow2 image" '[ "$(field /tmp/b.qcow2 format)" = qcow2 ]'
need "/tmp/b.qcow2's backing file is /tmp/a.qcow2 (qcow2)" '
	[ "$(readlink -f "$(field /tmp/b.qcow2 full-backing-filename)")" = /tmp/a.qcow2 ] && [ "$(field /tmp/b.qcow2 backing-filename-format)" = qcow2 ]'

task 3 "The main network interface's driver"
need "/root/lab-answers/3 has the driver of $IF${drv:+, $drv}" '[ -n "$drv" ] && [ "$(answer 3)" = "$drv" ]'
