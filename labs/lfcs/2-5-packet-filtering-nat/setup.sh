IF=$(ip -4 route show default | awk '{for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit }}')
[ -n "$IF" ] || die "no default route; this lab needs a working network"
state_set if "$IF"
state_set ip-forward "$(sysctl -n net.ipv4.ip_forward)"
ls /etc/sysctl.d >"$LAB_STATE/sysctl-d"
peer_up

if is_rhel; then
	pkg_install firewalld nftables
	pkg_installed firewalld && systemctl is-active --quiet firewalld && state_set firewalld-was-active 1
	tar -C /etc -cf "$LAB_STATE/firewalld.tar" firewalld
	systemctl enable --now --quiet firewalld
	firewall-cmd -q --state
	# The starting point: SSH and cockpit allowed, as on a fresh install.
	z=$(firewall-cmd --get-zone-of-interface="$IF" 2>/dev/null || firewall-cmd --get-default-zone)
	for s in ssh cockpit; do
		firewall-cmd -q --permanent --zone="$z" --query-service=$s || firewall-cmd -q --permanent --zone="$z" --add-service=$s
	done
	firewall-cmd -q --reload
else
	pkg_installed nftables || pkg_install nftables
	ufw status | grep -q 'Status: active' && state_set ufw-was-active 1
	tar -C /etc -cf "$LAB_STATE/ufw.tar" ufw default/ufw
	[ -f /etc/nftables.conf ] && cp -a /etc/nftables.conf "$LAB_STATE/nftables.conf"
fi

# The app on 8080, and the peer's sshd, test web server and firewall loader.
mkdir -p /srv/le-app /srv/le-peer-web
echo 'Lab app on port 8080' >/srv/le-app/index.html
echo 'Peer test page' >/srv/le-peer-web/index.html
cat >/etc/systemd/system/le-lab-app.service <<'X'
[Unit]
Description=Practice lab app on port 8080
After=network.target

[Service]
ExecStart=/usr/bin/python3 -m http.server 8080 --directory /srv/le-app

[Install]
WantedBy=multi-user.target
X
cat >/etc/systemd/system/le-lab-peer-sshd.service <<'X'
[Unit]
Description=Practice lab sshd on the peer
Requires=le-lab-peer.service
After=le-lab-peer.service network.target

[Service]
NetworkNamespacePath=/run/netns/lepeer
ExecStartPre=/bin/mkdir -p /run/sshd
ExecStart=/usr/sbin/sshd -D -o ListenAddress=10.99.0.2:22 -o PidFile=none
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
X
cat >/etc/systemd/system/le-lab-peer-web.service <<'X'
[Unit]
Description=Practice lab test web server on the peer
Requires=le-lab-peer.service
After=le-lab-peer.service

[Service]
NetworkNamespacePath=/run/netns/lepeer
ExecStart=/usr/bin/python3 -m http.server 8000 --bind 10.99.0.2 --directory /srv/le-peer-web

[Install]
WantedBy=multi-user.target
X
cat >/etc/systemd/system/le-lab-peer-nftables.service <<'X'
[Unit]
Description=Practice lab: the peer's nftables rules
Requires=le-lab-peer.service
After=le-lab-peer.service
ConditionPathExists=/etc/netns/lepeer/nftables.conf

[Service]
Type=oneshot
RemainAfterExit=yes
NetworkNamespacePath=/run/netns/lepeer
ExecStart=/usr/sbin/nft -f /etc/netns/lepeer/nftables.conf

[Install]
WantedBy=multi-user.target
X
mkdir -p /etc/netns/lepeer
systemctl daemon-reload
systemctl enable --now --quiet le-lab-app.service le-lab-peer-sshd.service le-lab-peer-web.service
