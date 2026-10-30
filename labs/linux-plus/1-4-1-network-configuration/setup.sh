[ -e /sys/class/net/lab0 ] && refuse "an interface lab0 already exists; remove it first"
if is_rhel; then
	command -v nmcli >/dev/null && systemctl is-active --quiet NetworkManager ||
		refuse "this lab needs NetworkManager running"
	nmcli -g NAME connection show | grep -qx lab0 && refuse "a NetworkManager connection lab0 already exists; delete it first"
else
	command -v netplan >/dev/null && systemctl is-active --quiet systemd-networkd ||
		refuse "this lab needs Netplan with systemd-networkd"
	[ -e /etc/netplan/90-lab.yaml ] && refuse "/etc/netplan/90-lab.yaml already exists; remove it first"
fi
grep -Eq '^[^#]*[[:space:]]labtest([[:space:]]|$)' /etc/hosts && refuse "/etc/hosts already has labtest; remove that line first"

if is_rhel; then
	nmcli -w 20 connection add type dummy ifname lab0 con-name lab0 \
		ipv4.method manual ipv4.addresses 192.168.76.1/24 ipv6.method disabled >/dev/null
	nmcli -w 20 connection up lab0 >/dev/null
else
	mkdir -p /etc/systemd/network
	printf '[NetDev]\nName=lab0\nKind=dummy\n' >/etc/systemd/network/10-le-lab0.netdev
	networkctl reload
	for i in $(seq 20); do [ -e /sys/class/net/lab0 ] && break; sleep 0.5; done
	[ -e /sys/class/net/lab0 ]
fi
