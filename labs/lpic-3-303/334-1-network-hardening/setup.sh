for p in /root/radius.pcapng; do [ -e $p ] && refuse "$p already exists; move it away and start again"; done
# Reset removes every package installed from here on, by setup or by the
# tasks, and only those.
pkgs_now() { if is_rhel; then rpm -qa --qf '%{NAME}\n'; else dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }'; fi | sort -u; }
pkgs_now >"$LAB_STATE/pkgs-before"
# Saved for reset: RADIUS's, radvd's and the firewall's configuration.
for d in etc/raddb etc/freeradius etc/radvd.conf; do [ -e /$d ] && printf '%s\n' "$d" >>"$LAB_STATE/saved"; done
[ -s "$LAB_STATE/saved" ] && tar -C / -cf "$LAB_STATE/conf.tar" $(cat "$LAB_STATE/saved")
for s in radiusd freeradius radvd; do enabled $s && printf '%s\n' $s >>"$LAB_STATE/enabled"; done
if systemctl is-active --quiet firewalld; then
	tar -C /etc -cf "$LAB_STATE/firewalld.tar" firewalld
elif command -v ufw >/dev/null && ufw status | grep -q 'Status: active'; then
	tar -C /etc -cf "$LAB_STATE/ufw.tar" ufw
fi

# The peer, and the rogue DHCP server in it, offering a router of its own.
peer_up
in_peer sysctl -qw net.ipv6.conf.le-peer.accept_ra=1
pkg_install dnsmasq/dnsmasq-base
state_set router "10.99.0.$((200 + RANDOM % 50))"
cat >/etc/systemd/system/le-lab-peer-dhcp.service <<X
[Unit]
Description=Practice lab: a rogue DHCP server on the peer
Requires=le-lab-peer.service
After=le-lab-peer.service

[Service]
NetworkNamespacePath=/run/netns/lepeer
ExecStart=/usr/sbin/dnsmasq -k --conf-file=/dev/null --port=0 --interface=le-peer --bind-interfaces --dhcp-range=10.99.0.100,10.99.0.150,1h --dhcp-option=3,$(state_get router) --dhcp-leasefile=/run/le-lab-peer-dhcp.leases --pid-file=/run/le-lab-peer-dhcp.pid

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-peer-dhcp.service
