# The PCI driver and the network driver of the VM's network card.
nic_drivers() {
	local i dev
	i=$(ip route show default | awk '{for (n = 1; n < NF; n++) if ($n == "dev") {print $(n + 1); exit}}')
	[ -n "$i" ] || i=$(ls /sys/class/net | grep -v '^lo$' | head -n1)
	dev=$(readlink -f "/sys/class/net/$i/device")
	basename "$(readlink -f "$dev/driver")"
	basename "$(readlink -f "$dev/../driver")"
}
driver_ok() {
	local a d
	a=$(answer 1 | tr _ -)
	[ -n "$a" ] || return 1
	for d in $(nic_drivers); do [ "$(printf '%s' "$d" | tr _ -)" = "$a" ] && return 0; done
	return 1
}
new_blacklist() {
	local f
	for f in $(grep -lsE '^[[:space:]]*blacklist[[:space:]]+pcspkr\b' /etc/modprobe.d/*.conf); do
		grep -qxF "$f" "$LAB_STATE/old-blacklists" || return 0
	done
	return 1
}

task 1 "The network card's kernel driver named"
need "/root/lab-answers/1 names the driver lspci -k shows for the Ethernet controller" driver_ok

task 2 "A module unloaded and loaded again" self

task 3 "pcspkr blacklisted, the VM rebooted, then pcspkr loaded by hand"
need "a file in /etc/modprobe.d/ blacklists pcspkr" new_blacklist
need "modprobe's configuration includes the blacklist" 'modprobe --showconfig | grep -qx "blacklist pcspkr"'
need "the VM has been rebooted since the lab started" '[ "$(cat /proc/sys/kernel/random/boot_id)" != "$(state_get boot-id)" ]'
need "pcspkr is loaded now (by hand, with modprobe)" 'grep -q "^pcspkr " /proc/modules'
