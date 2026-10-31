norm() { tr A-Z a-z | tr -d '[:space:]' | tr '-' ':'; }
line() { sed -n "${2}p" "/root/lab-answers/$1" 2>/dev/null | norm; }
dev=$(ip route show default | awk '{for (i = 1; i < NF; i++) if ($i == "dev") {print $(i + 1); exit}}')
gw=$(ip route show default | awk '{print $3; exit}')
mac=$(cat "/sys/class/net/$dev/address" 2>/dev/null)
gw_mac() {
	ping -c1 -W2 "$gw" >/dev/null 2>&1
	ip neigh show "$gw" dev "$dev" | awk '{for (i = 1; i < NF; i++) if ($i == "lladdr") print $(i + 1)}' | head -n1
}

task 1 "Your MAC, its maker's prefix, and the gateway's MAC"
need "line 1 of /root/lab-answers/1 is the MAC of $dev" '[ -n "$mac" ] && [ "$(line 1 1)" = "$mac" ]'
need "line 2 is the maker's prefix (its first three bytes)" '[ "$(line 1 2 | tr -d :)" = "$(printf %s "$mac" | cut -c1-8 | tr -d :)" ]'
need "line 3 is the MAC of the gateway $gw" 'g=$(gw_mac); [ -n "$g" ] && [ "$(line 1 3)" = "$g" ]'

task 2 "The peer's MAC from its ARP reply"
need "/root/lab-answers/2 is the peer's MAC" '[ "$(line 2 1)" = "$(in_peer cat /sys/class/net/le-peer/address)" ]'

task 3 "The free address found with arping"
need "iputils-arping is installed" 'pkg_installed iputils-arping'
need "/root/lab-answers/3 is the free address" '[ "$(line 3 1)" = "$(state_get free)" ]'
