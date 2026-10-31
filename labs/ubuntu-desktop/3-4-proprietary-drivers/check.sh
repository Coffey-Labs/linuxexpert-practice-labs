line() { sed -n "${2}p" "/root/lab-answers/$1" 2>/dev/null | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | tr A-Z a-z; }
component() { local s; s=$(apt-cache show "$1" 2>/dev/null | awk '$1 == "Section:" {print $2; exit}'); [ -n "$s" ] || return; case $s in */*) printf '%s' "${s%%/*}" ;; *) printf main ;; esac; }
needs_driver() { [ -n "$(timeout 120 ubuntu-drivers devices 2>/dev/null | grep -v '^[[:space:]]*$')" ]; }
sb_ok() {
	local a; a=$(line 2 3); s=$(mokutil --sb-state 2>&1)
	case $s in
	*"SecureBoot enabled"*) [ "$a" = enabled ] ;;
	*"SecureBoot disabled"*) [ "$a" = disabled ] ;;
	*) [[ $a =~ (no|not|bios|legacy|unsupported|efi) ]] && [ "$a" != enabled ] && [ "$a" != disabled ] ;;
	esac
}
# PCI network controllers and the driver each uses, as lspci -k shows it.
net_drivers() { lspci -k 2>/dev/null | awk '/^[^[:space:]]/ {net = ($0 ~ /(Ethernet|Network) controller/)} net && /Kernel driver in use:/ {print $NF}'; }
# Accepted names: lspci's, and the network interfaces' own drivers.
ok_drivers() {
	net_drivers
	for d in /sys/class/net/*/device/driver; do [ -e "$d" ] && basename "$(readlink -f "$d")"; done
}
given() { grep -v '^[[:space:]]*$' /root/lab-answers/3 2>/dev/null | sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s/.*:[[:space:]]*//'; }

task 1 "Whether this machine needs a proprietary driver"
need "/root/lab-answers/1 says yes or no, matching ubuntu-drivers devices" 'a=$(line 1 1); if needs_driver; then [ "$a" = yes ]; else [ "$a" = no ]; fi'

task 2 "Components of the NVIDIA and Broadcom drivers, Secure Boot state"
need "line 1 of /root/lab-answers/2 is nvidia-driver-580's component" 'c=$(component nvidia-driver-580); [ -n "$c" ] && [ "$(line 2 1)" = "$c" ]'
need "line 2 is bcmwl-kernel-source's component" 'c=$(component bcmwl-kernel-source); [ -n "$c" ] && [ "$(line 2 2)" = "$c" ]'
need "line 3 is this machine's Secure Boot state (mokutil --sb-state)" sb_ok

task 3 "Kernel driver of each network device"
need "/root/lab-answers/3 has a line for each network device" '[ "$(given | wc -l)" -ge "$(net_drivers | wc -l)" ] && [ "$(given | wc -l)" -ge 1 ]'
need "every line is a network device's driver in use" '[ -z "$(comm -23 <(given | sort -u) <(ok_drivers | sort -u))" ]'
