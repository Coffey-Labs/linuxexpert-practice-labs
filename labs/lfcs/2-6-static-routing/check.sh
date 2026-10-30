# firewalld, if it runs, lets this VM forward between le-host and le-far:
# both in one zone that forwards, or a policy from one's zone to the
# other's, now and permanently.
fw_forwards() {
	local zp zf pol p
	systemctl is-active --quiet firewalld || return 0
	for p in "" --permanent; do
		zp=$(firewall-cmd $p --get-zone-of-interface=le-host 2>/dev/null) || return 1
		zf=$(firewall-cmd $p --get-zone-of-interface=le-far 2>/dev/null) || return 1
		if [ "$zp" = "$zf" ]; then
			firewall-cmd $p --zone="$zp" --query-forward || return 1
		else
			for pol in $(firewall-cmd $p --get-policies); do
				firewall-cmd $p --policy="$pol" --list-ingress-zones | grep -Eqw "$zp|$zf|ANY" &&
					firewall-cmd $p --policy="$pol" --list-egress-zones | grep -Eqw "$zp|$zf|ANY" &&
					continue 2
			done
			return 1
		fi
	done
}

# Which gateway the kernel uses for $1.
gw_for() { ip route get "$1" 2>/dev/null | awk '{for (i = 1; i < NF; i++) if ($i == "via") { print $(i + 1); exit }}'; }
if is_rhel; then
	CON=$(nmcli -g GENERAL.CONNECTION device show le-net2 2>/dev/null)
	prof() { nmcli -g "$1" connection show "$CON" 2>/dev/null | tr -d '\\'; }
	saved_route() { prof ipv4.routes | tr ',' '\n' | grep -Eq "^ *$1 $2( |$)"; }
else
	NP=$(mktemp -d)
	trap 'rm -rf "$NP"' EXIT
	mkdir -p "$NP/etc" && cp -a /etc/netplan "$NP/etc/" && netplan generate --root-dir "$NP" >/dev/null 2>&1
	saved_route() { cat "$NP"/run/systemd/network/*le-net2*.network 2>/dev/null | grep -A1 -x "Destination=$1" | grep -qx "Gateway=$2"; }
fi

task 1 "A persistent route to 10.20.0.0/16 via 10.98.0.254" rhel
need "ip route get 10.20.1.1 shows 10.98.0.254" '[ "$(gw_for 10.20.1.1)" = 10.98.0.254 ]'
need "le-net2's profile has the route" 'saved_route 10.20.0.0/16 10.98.0.254'

task 2 "A persistent route to 10.20.0.0/16 via 10.98.0.254, with netplan" debian
need "ip route get 10.20.1.1 shows 10.98.0.254" '[ "$(gw_for 10.20.1.1)" = 10.98.0.254 ]'
need "netplan has the route for le-net2" 'saved_route 10.20.0.0/16 10.98.0.254'

task 3 "10.20.5.0/24 via 10.98.0.253, and the prediction in /root/lab-answers/3"
need "ip route get 10.20.5.9 shows 10.98.0.253" '[ "$(gw_for 10.20.5.9)" = 10.98.0.253 ]'
need "the route is saved" 'saved_route 10.20.5.0/24 10.98.0.253'
need "10.20.6.9 still goes via 10.98.0.254" '[ "$(gw_for 10.20.6.9)" = 10.98.0.254 ]'
need "the answer's first line is 10.20.5.9's gateway" 'sed -n 1p /root/lab-answers/3 | grep -qw "10\.98\.0\.253"'
need "the answer's second line is 10.20.6.9's gateway" 'sed -n 2p /root/lab-answers/3 | grep -qw "10\.98\.0\.254"'

task 4 "le-net2 never installs a default route" rhel
need "the le-net2 profile won't add a default route" '[ "$(prof ipv4.never-default)" = yes ] || [ -z "$(prof ipv4.gateway)" ]'
need "le-net2 is up" 'ip -4 addr show dev le-net2 | grep -q "10\.98\.0\.1/24"'
need "there is one default route, through the main interface" '[ "$(ip -4 route show default | wc -l)" = 1 ] && ! ip -4 route show default | grep -q le-net2'

task 5 "This VM routes between the peer and far"
need "forwarding is on, now and at boot" '[ "$(sysctl -n net.ipv4.ip_forward)" = 1 ] && grep -rqsE "^[[:space:]]*net[./]ipv4[./]ip_forward[[:space:]]*=[[:space:]]*1" /etc/sysctl.conf /etc/sysctl.d /etc/ufw/sysctl.conf'
need "the peer's settings have a route through 10.99.0.1" 'grep -Eq "^[^#]*via 10\.99\.0\.1([[:space:]]|$)" /etc/netns/lepeer/network'
need "far's settings have a route through 10.97.0.1" 'grep -Eq "^[^#]*via 10\.97\.0\.1([[:space:]]|$)" /etc/netns/le-far/network'
need "firewalld forwards between le-host and le-far (one zone with forwarding, or a policy)" fw_forwards
need "the peer can ping far" 'in_peer ping -c1 -W2 10.97.0.2'
need "far can ping the peer" 'ip netns exec le-far ping -c1 -W2 10.99.0.2'
need "tracepath from the peer to far shows 10.99.0.1 as the first hop" 'in_peer tracepath -n -m 3 10.97.0.2 | grep -Eq "^ *1: +10\.99\.0\.1 "'
