# Every driver between the root filesystem's disk and the bus it hangs off.
root_drivers() {
	local src disk p
	src=$(findmnt -n -o SOURCE / | sed 's/\[.*//')
	disk=$(lsblk -nspo NAME "$src" | tail -n1)
	p=$(readlink -f "/sys/class/block/${disk##*/}/device")
	while [ -n "$p" ] && [ "$p" != /sys/devices ] && [ "$p" != / ]; do
		[ -e "$p/driver" ] && basename "$(readlink -f "$p/driver")"
		p=${p%/*}
	done
}

task 1 "The license of the xfs module"
need "/root/lab-answers/1 has xfs's license, $(modinfo -F license xfs 2>/dev/null)" '[ "$(answer 1)" = "$(modinfo -F license xfs | tr A-Z a-z)" ]'

task 2 "dummy loaded with numdummies=3, then unloaded" self

task 3 "dummy loads at every boot with one device"
need "dummy is set to load at boot" '
	cat /etc/modules-load.d/*.conf /run/modules-load.d/*.conf /usr/lib/modules-load.d/*.conf /etc/modules 2>/dev/null | grep -Eq "^[[:space:]]*dummy[[:space:]]*$"'
need "modprobe gives dummy numdummies=1 (the last setting wins)" 'modprobe --show-depends dummy 2>/dev/null | grep -o "numdummies=[0-9]*" | tail -n1 | grep -qx numdummies=1'
need "the dummy module is loaded" '[ -d /sys/module/dummy ]'
need "ip -br link show type dummy shows one device" '[ "$(ip -br link show type dummy | wc -l)" = 1 ]'

task 4 "The root disk's driver"
need "/root/lab-answers/4 names a driver of the root disk ($(root_drivers | head -n1))" '[ -n "$(answer 4)" ] && root_drivers | grep -qxF "$(answer 4 | tr - _)"'
