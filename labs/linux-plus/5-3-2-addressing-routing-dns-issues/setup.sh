grep -q '^192\.0\.2\.99[[:space:]].*www\.kernel\.org' /etc/hosts && refuse "/etc/hosts already has a 192.0.2.99 line for www.kernel.org; remove it and start again"
peer_up
mkdir -p /etc/netns/lepeer
cat >/etc/netns/lepeer/network <<'Y'
# The peer's network settings, applied inside the peer at every boot with
# "ip -batch" (each line is an ip command without the leading "ip").
address replace 10.99.0.2/24 dev le-peer
route del default
Y
mkdir -p /usr/local/lib/le-lab
cat >/usr/local/lib/le-lab/peer-net.sh <<'Y'
#!/bin/sh
# The far side, 198.51.100.9, on this VM; then the peer's own settings.
ip link show le-far >/dev/null 2>&1 || ip link add le-far type dummy
ip addr replace 198.51.100.9/32 dev le-far
ip link set le-far up
ip -n lepeer -force -batch /etc/netns/lepeer/network
true
Y
chmod 755 /usr/local/lib/le-lab/peer-net.sh
if [ -d /etc/NetworkManager/conf.d ]; then
	printf '[keyfile]\nunmanaged-devices=interface-name:le-host;interface-name:le-far\n' \
		>/etc/NetworkManager/conf.d/91-le-lab-far.conf
	systemctl reload NetworkManager 2>/dev/null || true
fi
cat >/etc/systemd/system/le-lab-peer-net.service <<'Y'
[Unit]
Description=Practice lab: the peer's network settings
Requires=le-lab-peer.service
After=le-lab-peer.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/lib/le-lab/peer-net.sh

[Install]
WantedBy=multi-user.target
Y
systemctl daemon-reload
systemctl enable --now --quiet le-lab-peer-net.service
# Task 3: a wrong address for www.kernel.org.
hosts_add "192.0.2.99 www.kernel.org"
true
