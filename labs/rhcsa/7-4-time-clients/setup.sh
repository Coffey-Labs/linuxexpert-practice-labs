pkg_installed chrony || pkg_install chrony
cp -a /etc/chrony.conf "$LAB_STATE/chrony.conf"
enabled chronyd && state_set chronyd-enabled 1
tz=$(timedatectl show -p Timezone --value)
state_set timezone "$tz"
[ "$tz" != America/Phoenix ] || timedatectl set-timezone UTC
peer_up
hosts_add "$LE_PEER_ADDR ntp1.lab.example ntp1"
# The time server: chronyd in the peer, serving the VM's own clock and
# never changing it.
mkdir -p /etc/le-lab
cat >/etc/le-lab/ntp1.conf <<'X'
# The lab's time server, ntp1.
local stratum 8
allow 10.99.0.0/24
bindaddress 10.99.0.2
cmdport 0
bindcmdaddress /
pidfile /run/chrony/ntp1.pid
X
cat >/etc/systemd/system/le-lab-ntp1.service <<X
[Unit]
Description=LINUXexpert practice lab time server ntp1
Requires=le-lab-peer.service
After=le-lab-peer.service

[Service]
NetworkNamespacePath=/run/netns/$LE_PEER_NS
ExecStart=/usr/sbin/chronyd -d -x -f /etc/le-lab/ntp1.conf

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-ntp1.service
