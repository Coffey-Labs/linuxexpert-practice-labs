BOND=/proc/net/bonding/bond0
# member_up IF: IF is in bond0 with its link up.
member_up() { awk -v m="$1" '/^Slave Interface:/ {s = $3} s == m && /^MII Status:/ {print $3; exit}' "$BOND" 2>/dev/null | grep -qx up; }
# Take the active member's switch end down, ping, and put it back.
failover() {
	local a rc
	a=$(awk -F': ' '/^Currently Active Slave/ {print $2}' "$BOND")
	[ -n "$a" ] || return 1
	ip -n le-sw link set "${a}s" down
	sleep 1
	ping -c1 -W3 10.96.0.254; rc=$?
	ip -n le-sw link set "${a}s" up
	sleep 1
	return $rc
}
if is_rhel; then
	# A saved profile (not one made up for a device set up by hand).
	saved() { nmcli -t -f DEVICE,FILENAME connection show --active | grep -q "^$1:/etc/"; }
else
	NP=$(mktemp -d)
	trap 'rm -rf "$NP"' EXIT
	mkdir -p "$NP/etc" && cp -a /etc/netplan "$NP/etc/" && netplan generate --root-dir "$NP" >/dev/null 2>&1
	gen() { cat "$NP"/run/systemd/network/*-"$1".$2 2>/dev/null | grep -Eqx "$3"; }
fi
in_lan() { ip netns exec le-lan "$@"; }

bond_needs() {
	need "bond0 exists" '[ -f "$BOND" ]'
	need "bond0's mode is active-backup" 'grep -q "^Bonding Mode: fault-tolerance (active-backup)" "$BOND"'
	need "bond0 checks its links (miimon)" 'grep -Eq "^MII Polling Interval \(ms\): [1-9]" "$BOND"'
	need "le-b0 and le-b1 are in bond0 and up" 'member_up le-b0 && member_up le-b1'
	need "bond0 has 10.96.0.1/24, set statically" 'ip -4 -o addr show dev bond0 | grep " 10\.96\.0\.1/24 " | grep -vq dynamic'
	need "10.96.0.254 answers through bond0" 'ping -c1 -W2 10.96.0.254'
	need "pings keep working with the active member down" failover
}

task 1 "Active-backup bond0 from le-b0 and le-b1, with NetworkManager" rhel
bond_needs
need "bond0 and its members have saved profiles" 'saved bond0 && saved le-b0 && saved le-b1'

task 2 "Active-backup bond0 from le-b0 and le-b1, with netplan" debian
bond_needs
need "netplan has bond0 in active-backup mode" 'gen bond0 netdev "Kind=bond" && gen bond0 netdev "Mode=active-backup"'
need "netplan has le-b0 and le-b1 in bond0" 'gen le-b0 network "Bond=bond0" && gen le-b1 network "Bond=bond0"'

task 3 "Bridge br0 with le-p0 as its port and 10.95.0.1/24"
need "le-p0 is a port of br0, forwarding" 'bridge link show dev le-p0 | grep -q "master br0 .*state forwarding"'
need "br0 has 10.95.0.1/24" 'ip -4 -o addr show dev br0 | grep -q " 10\.95\.0\.1/24 "'
need "le-p0 has no address of its own" '! ip -4 -o addr show dev le-p0 | grep -q inet'
need "lan reaches this VM at 10.95.0.1" 'in_lan ping -c1 -W2 10.95.0.1'
if is_rhel; then
	need "br0 and le-p0 have saved profiles" 'saved br0 && saved le-p0'
else
	need "netplan has br0 with le-p0 in it" 'gen br0 netdev "Kind=bridge" && gen le-p0 network "Bridge=br0" && gen br0 network "Address=10\.95\.0\.1/24"'
fi

task 4 "The guest on br0, reachable from lan"
need "le-vnet0 is a port of br0, forwarding" 'bridge link show dev le-vnet0 | grep -q "master br0 .*state forwarding"'
need "lan reaches the guest at 10.95.0.50" 'in_lan ping -c1 -W2 10.95.0.50'
if is_rhel; then
	need "le-vnet0 has a saved profile" 'saved le-vnet0'
else
	need "netplan has le-vnet0 in br0" 'gen le-vnet0 network "Bridge=br0"'
fi
