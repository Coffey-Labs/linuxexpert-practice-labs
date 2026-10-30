for u in le-lab-app le-lab-peer-sshd le-lab-peer-web le-lab-peer-nftables; do
	systemctl disable --now --quiet "$u.service" 2>/dev/null
	rm -rf "/etc/systemd/system/$u.service" "/etc/systemd/system/$u.service.d"
done
systemctl daemon-reload
rm -rf /srv/le-app /srv/le-peer-web /etc/netns/lepeer/nftables.conf
rmdir /etc/netns/lepeer /etc/netns 2>/dev/null

if is_rhel; then
	if [ -f "$LAB_STATE/firewalld.tar" ]; then
		rm -rf /etc/firewalld
		tar -C /etc -xf "$LAB_STATE/firewalld.tar"
	fi
	if [ -n "$(state_get firewalld-was-active)" ]; then
		firewall-cmd -q --reload
	else
		systemctl disable --now --quiet firewalld
	fi
else
	[ -n "$(state_get ufw-was-active)" ] || ufw --force disable >/dev/null
	if [ -f "$LAB_STATE/ufw.tar" ]; then
		rm -rf /etc/ufw
		tar -C /etc -xf "$LAB_STATE/ufw.tar"
	fi
	[ -n "$(state_get ufw-was-active)" ] && ufw reload >/dev/null
	[ -f "$LAB_STATE/nftables.conf" ] && cp -a "$LAB_STATE/nftables.conf" /etc/nftables.conf
	systemctl is-active --quiet nftables && nft -f /etc/nftables.conf
fi

# Forwarding, as it was.
for f in /etc/sysctl.d/*; do
	[ -e "$f" ] || continue
	grep -qxF "${f##*/}" "$LAB_STATE/sysctl-d" 2>/dev/null && continue
	grep -q ip_forward "$f" && rm -f "$f"
done
sed -i -E '/^[[:space:]]*net\.ipv4\.ip_forward[[:space:]]*=[[:space:]]*1/d' /etc/sysctl.conf
v=$(state_get ip-forward)
[ -n "$v" ] && sysctl -qw net.ipv4.ip_forward="$v"
true
