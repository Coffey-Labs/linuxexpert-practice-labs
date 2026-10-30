if is_rhel; then
	# Profiles on the lab's interfaces, and on bond0 and br0.
	nmcli -t -f UUID,TYPE connection show | while IFS=: read -r uuid type; do
		i=$(nmcli -g connection.interface-name connection show "$uuid" 2>/dev/null)
		m=$(nmcli -g connection.master connection show "$uuid" 2>/dev/null)
		case "$i:$m" in
		le-b0:* | le-b1:* | le-p0:* | le-vnet0:* | bond0:* | br0:* | *:bond0 | *:br0) nmcli connection delete "$uuid" >/dev/null 2>&1 ;;
		esac
	done
	rm -f /etc/NetworkManager/conf.d/91-le-lab-bond.conf
	systemctl reload NetworkManager
elif [ -f "$LAB_STATE/netplan.tar" ]; then
	rm -rf /etc/netplan
	tar -C /etc -xf "$LAB_STATE/netplan.tar"
	netplan apply 2>/dev/null
fi
systemctl disable --now --quiet le-lab-bond-net.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-bond-net.service /usr/local/lib/le-lab/bond-net.sh
rmdir /usr/local/lib/le-lab 2>/dev/null
systemctl daemon-reload
for ns in le-sw le-lan le-guest; do ip netns del $ns 2>/dev/null; done
for i in le-b0 le-b1 le-p0 le-vnet0 bond0 br0; do ip link del $i 2>/dev/null; done
true
