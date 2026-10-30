IF=$(state_get if)
if is_rhel; then
	if [ -f "$LAB_STATE/nm.tar" ]; then
		rm -rf /etc/NetworkManager/system-connections/* /etc/NetworkManager/conf.d/*
		tar -C /etc/NetworkManager -xf "$LAB_STATE/nm.tar"
		nmcli connection reload
		nmcli general reload 2>/dev/null
		[ -n "$IF" ] && nmcli device reapply "$IF" >/dev/null 2>&1
	fi
else
	if [ -f "$LAB_STATE/netplan.tar" ] && ! tar -C /etc -df "$LAB_STATE/netplan.tar" >/dev/null 2>&1; then
		rm -rf /etc/netplan
		tar -C /etc -xf "$LAB_STATE/netplan.tar"
		netplan apply 2>/dev/null
	fi
	for f in /etc/cloud/cloud.cfg.d/*; do
		[ -e "$f" ] || continue
		grep -qxF "${f##*/}" "$LAB_STATE/cloud-cfg" 2>/dev/null || rm -f "$f"
	done
	[ -f "$LAB_STATE/resolved.conf" ] && cp -a "$LAB_STATE/resolved.conf" /etc/systemd/resolved.conf
	for f in /etc/systemd/resolved.conf.d/*; do
		[ -e "$f" ] || continue
		grep -qxF "${f##*/}" "$LAB_STATE/resolved-d" 2>/dev/null || rm -f "$f"
	done
	systemctl restart systemd-resolved
	resolvectl domain "$IF" "" 2>/dev/null
	networkctl reload 2>/dev/null
fi
sed -i -E '/^[^#]*[[:space:]]fake\.example\.org([[:space:]]|$)/d' /etc/hosts
true
