IF=$(ip -4 route show default | awk '{for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit }}')
[ -n "$IF" ] || refuse "no default route; this lab needs a working network"
state_set if "$IF"
state_set ip-forward "$(sysctl -n net.ipv4.ip_forward)"
ls /etc/sysctl.d >"$LAB_STATE/sysctl-d"

pkg_install firewalld nftables tcpdump
pkg_installed firewalld && systemctl is-active --quiet firewalld && state_set firewalld-was-active 1
tar -C /etc -cf "$LAB_STATE/firewalld.tar" firewalld
systemctl enable --now --quiet firewalld
firewall-cmd -q --state
z=$(firewall-cmd --get-zone-of-interface="$IF" 2>/dev/null || firewall-cmd --get-default-zone)
firewall-cmd -q --permanent --zone="$z" --query-service=ssh || firewall-cmd -q --permanent --zone="$z" --add-service=ssh
firewall-cmd -q --permanent --zone="$z" --query-masquerade && firewall-cmd -q --permanent --zone="$z" --remove-masquerade
firewall-cmd -q --permanent --info-policy int-to-pub >/dev/null 2>&1 && firewall-cmd -q --permanent --delete-policy int-to-pub
firewall-cmd -q --reload
peer_up
true
