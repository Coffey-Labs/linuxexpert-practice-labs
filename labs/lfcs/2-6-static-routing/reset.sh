systemctl disable --now --quiet le-lab-routing.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-routing.service /usr/local/lib/le-lab/routing-net.sh
rmdir /usr/local/lib/le-lab 2>/dev/null
systemctl daemon-reload
ip netns pids le-far 2>/dev/null | xargs -r kill 2>/dev/null
ip netns del le-far 2>/dev/null
ip link del le-far 2>/dev/null
rm -rf /etc/netns/le-far /etc/netns/lepeer/network
rmdir /etc/netns/lepeer /etc/netns 2>/dev/null

if is_rhel; then
	for c in $(nmcli -g UUID,DEVICE,NAME connection show | awk -F: '$2 == "le-net2" || $3 == "le-net2" {print $1}'); do
		nmcli connection delete "$c" >/dev/null 2>&1
	done
	grep -rls 'interface-name=le-net2' /etc/NetworkManager/system-connections 2>/dev/null | xargs -r rm -f
	nmcli connection reload
else
	if [ -f "$LAB_STATE/netplan.tar" ]; then
		rm -rf /etc/netplan
		tar -C /etc -xf "$LAB_STATE/netplan.tar"
		netplan apply 2>/dev/null
	fi
fi
ip link del le-net2 2>/dev/null

for f in /etc/sysctl.d/*; do
	[ -e "$f" ] || continue
	grep -qxF "${f##*/}" "$LAB_STATE/sysctl-d" 2>/dev/null && continue
	grep -q ip_forward "$f" && rm -f "$f"
done
sed -i -E '/^[[:space:]]*net\.ipv4\.ip_forward[[:space:]]*=[[:space:]]*1/d' /etc/sysctl.conf
v=$(state_get ip-forward)
[ -n "$v" ] && sysctl -qw net.ipv4.ip_forward="$v"
true
