state_set ip-forward "$(sysctl -n net.ipv4.ip_forward)"
ls /etc/sysctl.d >"$LAB_STATE/sysctl-d"

# The second network interface.
if is_rhel; then
	nmcli connection add type dummy ifname le-net2 con-name le-net2 \
		ipv4.method manual ipv4.addresses 10.98.0.1/24 \
		ipv4.gateway 10.98.0.254 ipv4.route-metric 900 ipv6.method disabled >/dev/null
	nmcli connection up le-net2 >/dev/null
else
	tar -C /etc -cf "$LAB_STATE/netplan.tar" netplan
	cat >/etc/netplan/60-le-net2.yaml <<'X'
# The lab's second network interface.
network:
  version: 2
  dummy-devices:
    le-net2:
      addresses: [10.98.0.1/24]
X
	chmod 600 /etc/netplan/60-le-net2.yaml
	netplan apply
fi

# Task 5: the peer, far, and this VM between them.
peer_up
mkdir -p /etc/netns/lepeer /etc/netns/le-far
cat >/etc/netns/lepeer/network <<'X'
# The peer's network settings, applied inside it at every boot with
# "ip -batch" (each line is an ip command without the leading "ip").
address replace 10.99.0.2/24 dev le-peer
X
cat >/etc/netns/le-far/network <<'X'
# far's network settings, applied inside it at every boot with
# "ip -batch" (each line is an ip command without the leading "ip").
address replace 10.97.0.2/24 dev le-far0
X
mkdir -p /usr/local/lib/le-lab
cat >/usr/local/lib/le-lab/routing-net.sh <<'X'
#!/bin/sh
ip netns list | grep -qw le-far || ip netns add le-far
ip link show le-far >/dev/null 2>&1 || ip link add le-far type veth peer name le-far0 netns le-far
ip addr replace 10.97.0.1/24 dev le-far
ip link set le-far up
ip -n le-far link set lo up
ip -n le-far link set le-far0 up
ip -n lepeer route del default 2>/dev/null
ip -n lepeer -force -batch /etc/netns/lepeer/network
ip -n le-far -force -batch /etc/netns/le-far/network
true
X
chmod 755 /usr/local/lib/le-lab/routing-net.sh
cat >/etc/systemd/system/le-lab-routing.service <<'X'
[Unit]
Description=Practice lab: the peer's and far's networks
Requires=le-lab-peer.service
After=le-lab-peer.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/lib/le-lab/routing-net.sh

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-routing.service
