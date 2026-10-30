timesvc() { for s in chronyd systemd-timesyncd; do active $s && { echo $s; return; }; done; }
dhcp_server() {
	if command -v nmcli >/dev/null && systemctl is-active --quiet NetworkManager; then
		nmcli -t -f DHCP4 device show 2>/dev/null | sed -n 's/.*dhcp_server_identifier = //p'
	fi
	cat /run/systemd/netif/leases/* 2>/dev/null | sed -n 's/^SERVER_ADDRESS=//p'
}
peer_dig() { in_peer dig +time=2 +tries=2 @10.99.0.1 "$@"; }

task 1 "The time service"
need "a time service is running" '[ -n "$(timesvc)" ]'
need "/root/lab-answers/1 names it" '[ "$(answer 1 | sed "s/\.service$//")" = "$(timesvc)" ] || { [ "$(timesvc)" = chronyd ] && [ "$(answer 1)" = chrony ]; }'

task 2 "Unbound answers the peer" rhel
need "unbound is running" active unbound
need "unbound starts at boot" enabled unbound
need "unbound listens on all addresses on port 53" 'ss -Hlnu "sport = :53" | grep -Eq "(0\.0\.0\.0|\*):53"'
need "the peer gets an answer from 10.99.0.1 (firewall open, access allowed)" 'peer_dig localhost | grep -q "status: NOERROR"'

task 3 "The DHCP server"
need "/root/lab-answers/3 has the DHCP server's address" 'a=$(answer 3); [ -n "$a" ] && dhcp_server | grep -qxF "$a"'
