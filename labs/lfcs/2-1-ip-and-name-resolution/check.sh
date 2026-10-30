IF=$(state_get if) GW=$(state_get gw) ADDR=$(state_get addr)
V6=2001:db8:10::20/64 GW6=2001:db8:10::1 EXTRA=192.0.2.21/24

# The profile (RHEL) or the configuration netplan generates (Ubuntu) for
# the main interface.
if is_rhel; then
	CON=$(nmcli -g GENERAL.CONNECTION device show "$IF" 2>/dev/null)
	# -g escapes colons in IPv6 addresses; drop the backslashes.
	prof() { nmcli -g "$1" connection show "$CON" 2>/dev/null | tr -d '\\'; }
else
	NP=$(mktemp -d)
	trap 'rm -rf "$NP"' EXIT
	mkdir -p "$NP/etc" && cp -a /etc/netplan "$NP/etc/" && netplan generate --root-dir "$NP" >/dev/null 2>&1
	NETWORK=$(grep -lE "^Name=$IF\$" "$NP"/run/systemd/network/*.network 2>/dev/null | head -n1)
	gen() { [ -n "$NETWORK" ] && grep -Eq "$1" "$NETWORK"; }
fi
live_addr() { ip -o addr show dev "$IF" | grep -F " $1 " | grep -vq dynamic; }

task 1 "Static IPv4 and IPv6 on the main interface with NetworkManager" rhel
need "$IF has a NetworkManager profile" '[ -n "$CON" ]'
need "the profile's IPv4 method is manual" '[ "$(prof ipv4.method)" = manual ]'
need "the profile has $ADDR, gateway $GW and a DNS server" 'prof ipv4.addresses | grep -qF "$ADDR" && [ "$(prof ipv4.gateway)" = "$GW" ] && [ -n "$(prof ipv4.dns)" ]'
need "the profile has $V6 with gateway $GW6" 'prof ipv6.addresses | grep -qF "$V6" && [ "$(prof ipv6.gateway)" = "$GW6" ]'
need "$IF has $ADDR as a static address" 'live_addr "$ADDR"'
need "$IF has $V6" 'live_addr "$V6"'
need "the default routes go via $GW and $GW6" 'ip -4 route show default | grep -q "via $GW dev $IF" && ip -6 route show default | grep -q "via $GW6 dev $IF"'
need "getent hosts example.org works" getent hosts example.org

task 2 "Static IPv4 and IPv6 on the main interface with netplan" debian
need "netplan configures $IF" '[ -n "$NETWORK" ]'
need "netplan doesn't use DHCP for IPv4 on $IF" '! gen "^DHCP=(yes|ipv4|true)"'
need "netplan gives $IF $ADDR and $V6" 'gen "^Address=$ADDR\$" && gen "^Address=$V6\$"'
need "netplan sets the gateways $GW and $GW6" 'gen "^Gateway=$GW\$" && gen "^Gateway=$GW6\$"'
need "netplan sets a DNS server for $IF" 'gen "^DNS="'
need "$IF has $ADDR as a static address" 'live_addr "$ADDR"'
need "$IF has $V6" 'live_addr "$V6"'
need "the default routes go via $GW and $GW6" 'ip -4 route show default | grep -q "via $GW dev $IF" && ip -6 route show default | grep -q "via $GW6 dev $IF"'
need "getent hosts example.org works" getent hosts example.org

task 3 "A second address, $EXTRA, on the main interface"
need "$IF still has $ADDR" 'ip -o addr show dev "$IF" | grep -qF " $ADDR "'
need "$IF has $EXTRA" 'ip -o addr show dev "$IF" | grep -qF " $EXTRA "'
if is_rhel; then
	need "the profile keeps both addresses" 'prof ipv4.addresses | grep -qF "$EXTRA"'
else
	need "netplan keeps both addresses" 'gen "^Address=$EXTRA\$"'
fi

task 4 "Hostname lab1.example.org; db1 is 192.168.122.30 without DNS"
need "hostname prints lab1.example.org" '[ "$(hostname)" = lab1.example.org ]'
need "/etc/hostname has lab1.example.org" 'grep -qx "lab1.example.org" /etc/hostname'
need "getent hosts db1 prints 192.168.122.30" 'getent hosts db1 | grep -q "^192\.168\.122\.30 "'
need "db1 is in /etc/hosts" 'grep -Eq "^192\.168\.122\.30[[:space:]].*\bdb1\b" /etc/hosts'

task 5 "example.org as a DNS search domain"
need "getent hosts www resolves www.example.org" 'getent hosts www | grep -q "example\.org"'
if is_rhel; then
	need "the search domain is in NetworkManager's configuration" 'grep -rqs "example\.org" /etc/NetworkManager/system-connections /etc/NetworkManager/conf.d'
else
	need "the search domain is in netplan or resolved's configuration" 'conf_has /etc/netplan /etc/systemd/resolved.conf /etc/systemd/resolved.conf.d "example\.org"'
fi
