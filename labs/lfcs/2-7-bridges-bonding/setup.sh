mkdir -p /usr/local/lib/le-lab
cat >/usr/local/lib/le-lab/bond-net.sh <<'X'
#!/bin/sh
# The lab's networks: a switch for the bond, a LAN for the bridge, and a
# guest. Run at every boot.
for ns in le-sw le-lan le-guest; do
	ip netns list | grep -qw $ns || ip netns add $ns
	ip -n $ns link set lo up
done
ip -n le-sw link show sw >/dev/null 2>&1 || ip -n le-sw link add sw type bridge
for i in 0 1; do
	ip link show le-b$i >/dev/null 2>&1 || ip link add le-b$i type veth peer name le-b${i}s netns le-sw
	ip -n le-sw link set le-b${i}s master sw up
done
ip -n le-sw addr replace 10.96.0.254/24 dev sw
ip -n le-sw link set sw up
ip link show le-p0 >/dev/null 2>&1 || ip link add le-p0 type veth peer name le-p0s netns le-lan
ip -n le-lan addr replace 10.95.0.2/24 dev le-p0s
ip -n le-lan link set le-p0s up
ip link show le-vnet0 >/dev/null 2>&1 || ip link add le-vnet0 type veth peer name eth0 netns le-guest
ip -n le-guest addr replace 10.95.0.50/24 dev eth0
ip -n le-guest link set eth0 up
true
X
chmod 755 /usr/local/lib/le-lab/bond-net.sh
cat >/etc/systemd/system/le-lab-bond-net.service <<'X'
[Unit]
Description=Practice lab: networks for bonds and bridges
Before=network-pre.target
Wants=network-pre.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/lib/le-lab/bond-net.sh

[Install]
WantedBy=multi-user.target
X

if is_rhel; then
	# NetworkManager leaves veth interfaces alone unless told otherwise.
	cat >/etc/NetworkManager/conf.d/91-le-lab-bond.conf <<'X'
[main]
no-auto-default+=interface-name:le-*

[device-le-lab-bond]
match-device=interface-name:le-b0;interface-name:le-b1;interface-name:le-p0;interface-name:le-vnet0
managed=1
X
	systemctl reload NetworkManager
fi
systemctl daemon-reload
systemctl enable --now --quiet le-lab-bond-net.service

# le-p0's address, the way the system keeps addresses.
if is_rhel; then
	nmcli connection add type ethernet ifname le-p0 con-name le-p0 \
		ipv4.method manual ipv4.addresses 10.95.0.1/24 ipv6.method disabled >/dev/null
	nmcli connection up le-p0 >/dev/null
else
	tar -C /etc -cf "$LAB_STATE/netplan.tar" netplan
	cat >/etc/netplan/60-le-lab.yaml <<'X'
# The lab's extra interfaces.
network:
  version: 2
  ethernets:
    le-p0:
      addresses: [10.95.0.1/24]
X
	chmod 600 /etc/netplan/60-le-lab.yaml
	netplan apply
fi
