# The spare interface: eth1, cabled to a small lab network,
# 192.168.50.0/24, where a machine answers at 192.168.50.1 (and
# fd00:50::1).
ip link show eth1 >/dev/null 2>&1 && refuse "this VM already has an eth1; the lab adds its own spare eth1"
command -v nmcli >/dev/null && systemctl is-active --quiet NetworkManager || refuse "this lab needs NetworkManager running"
mkdir -p /usr/local/lib/le-lab
cat >/usr/local/lib/le-lab/spare-net.sh <<'X'
#!/bin/sh
# The lab's spare network: eth1 here, the gateway 192.168.50.1 in the
# le-net50 namespace. Run at every boot.
ip netns list | grep -qw le-net50 || ip netns add le-net50
ip -n le-net50 link set lo up
ip link show eth1 >/dev/null 2>&1 || ip link add eth1 address 52:54:00:4c:45:01 type veth peer name gw netns le-net50
ip -n le-net50 addr replace 192.168.50.1/24 dev gw
ip -n le-net50 addr replace fd00:50::1/64 dev gw nodad
ip -n le-net50 link set gw up
true
X
chmod 755 /usr/local/lib/le-lab/spare-net.sh
cat >/etc/systemd/system/le-lab-spare-net.service <<'X'
[Unit]
Description=Practice lab: a spare network interface, eth1
Before=network-pre.target NetworkManager.service
Wants=network-pre.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/lib/le-lab/spare-net.sh

[Install]
WantedBy=multi-user.target
X
# NetworkManager manages eth1 but makes no profile for it on its own. A
# gateway and DNS server on eth1 rank below the main interface's, so the
# VM keeps its own way out.
cat >/etc/NetworkManager/conf.d/91-le-lab-spare.conf <<'X'
[main]
no-auto-default+=interface-name:eth1

[device-le-lab-spare]
match-device=interface-name:eth1
managed=1

[connection-le-lab-spare]
match-device=interface-name:eth1
ipv4.route-metric=500
ipv6.route-metric=500
ipv4.dns-priority=200
ipv6.dns-priority=200
X
systemctl reload NetworkManager
systemctl daemon-reload
systemctl enable --now --quiet le-lab-spare-net.service
for i in 1 2 3 4 5 6 7 8 9 10; do
	nmcli -g GENERAL.STATE device show eth1 2>/dev/null | grep -qv unmanaged && break
	sleep 1
done

# Note the profiles for eth1 and their IPv4 addresses (task 2 and 3).
cat >/usr/local/lib/le-lab/watch.sh <<'X'
#!/bin/bash
# Notes each change of what snap prints.
log=$1 prev=''
snap() {
	local u
	for u in $(nmcli -g UUID connection show 2>/dev/null); do
		[ "$(nmcli -g connection.interface-name connection show "$u" 2>/dev/null)" = eth1 ] || continue
		printf '%s=%s ' "$u" "$(nmcli -g ipv4.addresses connection show "$u" 2>/dev/null | tr -d ' ')"
	done
}
while :; do
	cur=$(snap)
	[ "$cur" = "$prev" ] || { printf '%s\n' "$cur" >>"$log"; prev=$cur; }
	sleep 2
done
X
cat >/etc/systemd/system/le-lab-watch.service <<X
[Unit]
Description=LINUXexpert practice lab: note the profiles for eth1
After=NetworkManager.service

[Service]
ExecStart=/bin/bash /usr/local/lib/le-lab/watch.sh $LAB_STATE/watch.log
Restart=always

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-watch.service
