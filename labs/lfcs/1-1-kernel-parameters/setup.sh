# Forwarding off, swappiness away from 10.
state_set swappiness "$(sysctl -n vm.swappiness)"
[ "$(sysctl -n vm.swappiness)" != 10 ] || sysctl -qw vm.swappiness=60
sysctl -qw net.ipv4.ip_forward=0

# Two linked interfaces for task 3, made again at every boot.
cat >/etc/systemd/system/le-lab-links.service <<'X'
[Unit]
Description=LINUXexpert practice lab interfaces lab0 and lab1
After=network-pre.target
Before=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/sh -c 'ip link show lab0 >/dev/null 2>&1 || ip link add lab0 type veth peer name lab1; ip link set lab0 up; ip link set lab1 up'

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --quiet --now le-lab-links.service

# Note whether the main interface has IPv6 now; task 3 must keep it.
main=$(ip route show default | awk '{print $5; exit}')
state_set main-if "$main"
if [ -n "$main" ] && [ -n "$(ip -6 -o addr show dev "$main")" ]; then state_set main-v6 yes; fi

modprobe -r dummy 2>/dev/null || true
