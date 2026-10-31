[ -e /etc/systemd/system/le-lab-l2.service ] && refuse "le-lab-l2.service exists; run le-lab reset first"
ip route show default | grep -q . || refuse "this VM has no default route; task 1 needs one"
if pkg_installed iputils-arping; then
	state_set had-arping 1
	DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge iputils-arping >/dev/null
fi
peer_up
# The peer gets a fixed MAC address and two of the three candidate
# addresses, again at every boot.
free=$((21 + RANDOM % 3))
state_set free "10.99.0.$free"
used=$(for n in 21 22 23; do [ "$n" = "$free" ] || printf ' 10.99.0.%s/24' "$n"; done)
cat >/etc/systemd/system/le-lab-l2.service <<UNIT
[Unit]
Description=LINUXexpert practice lab: addresses on the peer
After=le-lab-peer.service
Requires=le-lab-peer.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/sh -c 'ip -n lepeer link set le-peer address 02:4c:45:00:00:02; for a in$used; do ip -n lepeer addr add \$\$a dev le-peer 2>/dev/null; done; true'

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now --quiet le-lab-l2.service
