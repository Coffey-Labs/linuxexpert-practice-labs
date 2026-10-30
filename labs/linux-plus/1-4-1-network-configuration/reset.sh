sed -i -E '/^[^#]*[[:space:]]labtest([[:space:]]|$)/d' /etc/hosts
if is_rhel; then
	nmcli connection delete lab0 >/dev/null 2>&1
else
	rm -f /etc/netplan/90-lab.yaml /etc/systemd/network/10-le-lab0.netdev
	netplan generate 2>/dev/null
	networkctl reload 2>/dev/null
fi
ip link del lab0 2>/dev/null
true
