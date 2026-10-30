if is_rhel; then
	for c in $(nmcli -g UUID,DEVICE,NAME connection show 2>/dev/null | awk -F: '$2 == "le-lan" || $3 == "lab-net" {print $1}'); do
		nmcli connection delete "$c" >/dev/null 2>&1
	done
	systemctl disable --now --quiet le-lab-dhcp.service le-lab-lan.service 2>/dev/null
	rm -f /etc/systemd/system/le-lab-dhcp.service /etc/systemd/system/le-lab-lan.service
	systemctl daemon-reload
	ip link del le-lan 2>/dev/null
	rm -f /etc/NetworkManager/conf.d/92-le-lab-lan.conf
	systemctl reload NetworkManager 2>/dev/null
	rm -f /usr/local/lib/le-lab/lan-net.sh /var/lib/dnsmasq/le-lab.leases
	rmdir /usr/local/lib/le-lab 2>/dev/null
	[ -n "$(state_get added-dnsmasq)" ] && dnf -y -q remove dnsmasq >/dev/null 2>&1
fi
old=$(state_get hostname)
[ -n "$old" ] && [ "$(hostname)" != "$old" ] && hostnamectl set-hostname "$old"
sed -i -E '/^[^#]*[[:space:]]files\.lab\.example([[:space:]]|$)/d' /etc/hosts
true
