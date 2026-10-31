systemctl disable --now --quiet le-lab-peer-wg.service le-lab-peer-openvpn.service le-lab-peer-ipsec.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-peer-wg.service /etc/systemd/system/le-lab-peer-openvpn.service /etc/systemd/system/le-lab-peer-ipsec.service
rm -rf /etc/le-lab-peer-ipsec /etc/netns/lepeer/wireguard /etc/netns/lepeer/openvpn
rmdir /etc/netns/lepeer /etc/netns 2>/dev/null
systemctl disable --now --quiet wg-quick@wg0 openvpn-server@lab 2>/dev/null
command -v swanctl >/dev/null && timeout 15 swanctl --terminate --ike host-host >/dev/null 2>&1
rm -f /etc/swanctl/conf.d/lab.conf /etc/wireguard/wg0.conf /etc/openvpn/server/lab.conf \
	/etc/openvpn/server/ca.crt /etc/openvpn/server/server.crt /etc/openvpn/server/server.key /etc/openvpn/server/ta.key
ip link del wg0 2>/dev/null
rm -rf /root/vpn
systemctl daemon-reload
# The packages installed since setup started, and only those: not the
# dependencies they leave unneeded that were there before.
pkgs_now() { if is_rhel; then rpm -qa --qf '%{NAME}\n'; else dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }'; fi | sort -u; }
if [ -s "$LAB_STATE/pkgs-before" ]; then
	new=$(pkgs_now | comm -13 "$LAB_STATE/pkgs-before" - | grep -Ev '^(kernel|linux-)')
	if [ -n "$new" ]; then
		say "Removing the packages installed since the lab started..."
		if is_rhel; then
			dnf -y -q remove --setopt=clean_requirements_on_remove=False $new >/dev/null 2>&1
		else
			DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge $new >/dev/null 2>&1
		fi
	fi
fi
if pkg_installed charon-systemd; then
	if [ -n "$(state_get strongswan-was-active)" ]; then systemctl restart strongswan; else systemctl stop strongswan 2>/dev/null; fi
fi
if [ -f "$LAB_STATE/ufw.tar" ]; then
	rm -rf /etc/ufw && tar -C /etc -xf "$LAB_STATE/ufw.tar"
	ufw reload >/dev/null
fi
true
