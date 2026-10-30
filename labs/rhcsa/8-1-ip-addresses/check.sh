LOG=$LAB_STATE/watch.log
# The profile active on eth1, and its settings.
CON=$(nmcli -g GENERAL.CON-UUID device show eth1 2>/dev/null)
prof() { nmcli -g "$1" connection show "$CON" 2>/dev/null | tr -d '\\'; }
# UUIDs of every eth1 profile seen, in the order they appeared.
seen_uuids() { tr ' ' '\n' <"$LOG" 2>/dev/null | sed -n 's/=.*//p' | awk 'NF && !s[$0]++'; }
live() { ip -o addr show dev eth1 | grep -F " $1 " | grep -vq dynamic; }

task1_needs() {
	need "a profile is active on eth1" '[ -n "$CON" ]'
	need "the profile is saved in /etc (persistent)" 'nmcli -t -f UUID,FILENAME connection show | grep "^$CON:" | grep -q ":/etc/"'
	need "the profile starts at boot (autoconnect)" '[ "$(prof connection.autoconnect)" = yes ]'
	need "the profile's IPv4 method is manual with 192.168.50.10/24" '[ "$(prof ipv4.method)" = manual ] && prof ipv4.addresses | grep -q "192\.168\.50\.10/24"'
	need "the profile has gateway and DNS server 192.168.50.1" '[ "$(prof ipv4.gateway)" = 192.168.50.1 ] && prof ipv4.dns | grep -qw "192\.168\.50\.1"'
	need "the profile has fd00:50::10/64" 'prof ipv6.addresses | grep -q "fd00:50::10/64"'
	need "eth1 has 192.168.50.10/24 and fd00:50::10/64" 'live 192.168.50.10/24 && live fd00:50::10/64'
	need "ip route shows default via 192.168.50.1 dev eth1" 'ip -4 route show default | grep -q "via 192\.168\.50\.1 dev eth1"'
	need "/etc/resolv.conf lists nameserver 192.168.50.1" 'grep -q "^nameserver 192\.168\.50\.1$" /etc/resolv.conf'
	need "192.168.50.1 answers ping" 'ping -c1 -W2 192.168.50.1'
}

task 1 "eth1: 192.168.50.10/24, gateway and DNS 192.168.50.1, fd00:50::10/64"
task1_needs

task 2 "A second address, 192.168.50.11/24, on the same profile"
need "a profile for eth1 had both 192.168.50.10/24 and 192.168.50.11/24" 'tr " " "\n" <"$LOG" | grep "192\.168\.50\.10/24" | grep -q "192\.168\.50\.11/24"'

task 3 "The profile deleted and tasks 1 and 2 done again with nmtui"
need "a second, fresh profile for eth1 was made" '[ "$(seen_uuids | wc -l)" -ge 2 ]'
need "the first profile is gone" '! nmcli -g UUID connection show | grep -qx "$(seen_uuids | head -n1)"'
task1_needs
need "the fresh profile has 192.168.50.11/24 too" 'prof ipv4.addresses | grep -q "192\.168\.50\.11/24"'
need "eth1 has 192.168.50.11/24 too" 'live 192.168.50.11/24'
