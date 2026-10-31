if command -v nmcli >/dev/null; then
	nmcli -g UUID,NAME connection show 2>/dev/null | while IFS=: read -r uuid name; do
		[ "$name" = office ] || [ "$(nmcli -g connection.interface-name connection show "$uuid" 2>/dev/null)" = lab0 ] || continue
		nmcli connection delete "$uuid" >/dev/null 2>&1
		rm -f "/etc/netplan/90-NM-$uuid.yaml"
	done
fi
if [ -f /etc/systemd/system/le-lab-lab0.service ]; then
	systemctl disable --now --quiet le-lab-lab0.service 2>/dev/null
	rm -f /etc/systemd/system/le-lab-lab0.service
	systemctl daemon-reload
fi
ip link del lab0 2>/dev/null
if [ -s "$LAB_STATE/pkgs-added" ]; then
	DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge $(cat "$LAB_STATE/pkgs-added") >/dev/null 2>&1
fi
true
