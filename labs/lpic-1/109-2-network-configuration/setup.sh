if is_rhel; then
	command -v nmcli >/dev/null && systemctl is-active --quiet NetworkManager ||
		refuse "NetworkManager isn't running; this lab uses it"
else
	command -v netplan >/dev/null && systemctl is-active --quiet systemd-networkd ||
		refuse "this lab needs netplan with systemd-networkd"
	grep -qs le-lan /etc/netplan/*.yaml && refuse "a file in /etc/netplan already mentions le-lan; remove it first"
fi
ip link show le-lan >/dev/null 2>&1 && refuse "an interface le-lan already exists; remove it first"

state_set hostname "$(hostname)"
[ "$(hostname)" != lab2.example.net ] || hostnamectl set-hostname lab-vm
sed -i -E '/^[^#]*[[:space:]]files\.lab\.example([[:space:]]|$)/d' /etc/hosts
peer_up

# le-lan, linked to the peer, where 10.98.0.1 answers (and, on the RHEL
# family, a DHCP server).
mkdir -p /usr/local/lib/le-lab
cat >/usr/local/lib/le-lab/lan-net.sh <<'X'
#!/bin/sh
ip link show le-lan >/dev/null 2>&1 || ip link add le-lan type veth peer name le-lanp netns lepeer
ip -n lepeer addr replace 10.98.0.1/24 dev le-lanp
ip -n lepeer link set le-lanp up
ip link set le-lan up
command -v nmcli >/dev/null && nmcli device set le-lan managed yes 2>/dev/null
true
X
chmod 755 /usr/local/lib/le-lab/lan-net.sh
cat >/etc/systemd/system/le-lab-lan.service <<'X'
[Unit]
Description=Practice lab: the le-lan network
Requires=le-lab-peer.service
After=le-lab-peer.service NetworkManager.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/lib/le-lab/lan-net.sh

[Install]
WantedBy=multi-user.target
X

if is_rhel; then
	pkg_installed dnsmasq || { pkg_install dnsmasq; state_set added-dnsmasq 1; }
	cat >/etc/systemd/system/le-lab-dhcp.service <<'X'
[Unit]
Description=Practice lab DHCP server at 10.98.0.1, on the peer
Requires=le-lab-lan.service
After=le-lab-lan.service

[Service]
NetworkNamespacePath=/run/netns/lepeer
ExecStart=/usr/sbin/dnsmasq -k --conf-file=/dev/null --port=0 --pid-file= --bind-interfaces --interface=le-lanp --dhcp-range=10.98.0.100,10.98.0.150,1h --dhcp-leasefile=/var/lib/dnsmasq/le-lab.leases

[Install]
WantedBy=multi-user.target
X
	mkdir -p /var/lib/dnsmasq
	# No automatic "Wired connection" for le-lan: lab-net is its profile.
	printf '[main]\nno-auto-default=interface-name:le-lan\n' >/etc/NetworkManager/conf.d/92-le-lab-lan.conf
	systemctl reload NetworkManager 2>/dev/null || true
	systemctl daemon-reload
	systemctl enable --now --quiet le-lab-lan.service le-lab-dhcp.service
	nmcli connection delete lab-net >/dev/null 2>&1 || true
	nmcli connection add type ethernet ifname le-lan con-name lab-net \
		ipv4.method auto ipv6.method disabled >/dev/null
	timeout 60 nmcli connection up lab-net >/dev/null 2>&1 || warn "lab-net didn't get an address yet; try: nmcli connection up lab-net"
else
	# For reset to put back.
	tar -C /etc -cf "$LAB_STATE/netplan.tar" netplan
	systemctl daemon-reload
	systemctl enable --now --quiet le-lab-lan.service
fi
true
