IF=$(state_get if)
if is_rhel; then
	if [ -f "$LAB_STATE/nm.tar" ]; then
		rm -f /etc/NetworkManager/system-connections/*
		tar -C /etc/NetworkManager -xf "$LAB_STATE/nm.tar"
		nmcli connection reload
		uuid=$(state_get con-uuid)
		[ -n "$uuid" ] && timeout 60 nmcli connection up "$uuid" >/dev/null 2>&1
	fi
	grep -rlsx 'dns-search=example.org;\?' /etc/NetworkManager/conf.d | xargs -r rm -f
else
	if [ -f "$LAB_STATE/netplan.tar" ]; then
		rm -rf /etc/netplan
		tar -C /etc -xf "$LAB_STATE/netplan.tar"
		for f in /etc/cloud/cloud.cfg.d/*; do
			[ -e "$f" ] || continue
			grep -qxF "${f##*/}" "$LAB_STATE/cloud-cfg" 2>/dev/null || rm -f "$f"
		done
		netplan apply 2>/dev/null
	fi
	for f in /etc/systemd/resolved.conf.d/*; do
		[ -e "$f" ] || continue
		grep -qxF "${f##*/}" "$LAB_STATE/resolved-d" 2>/dev/null || rm -f "$f"
	done
	sed -i -E '/^[[:space:]]*Domains=.*example\.org/d' /etc/systemd/resolved.conf
	systemctl restart systemd-resolved
fi
old=$(state_get hostname)
[ -n "$old" ] && hostnamectl set-hostname "$old"
sed -i -E '/^192\.168\.122\.30[[:space:]]/d; /lab1\.example\.org/d' /etc/hosts
rm -f /root/lab-network.txt
true
