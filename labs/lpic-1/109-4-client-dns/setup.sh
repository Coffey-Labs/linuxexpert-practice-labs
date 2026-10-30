IF=$(ip -4 route show default | awk '{for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit }}')
[ -n "$IF" ] || refuse "no default route; this lab needs a working network"
state_set if "$IF"
# Who writes resolv.conf.
r=$(readlink -f /etc/resolv.conf)
if [[ $r == /run/systemd/resolve/* ]]; then state_set writer resolved
elif grep -q 'NetworkManager' /etc/resolv.conf; then state_set writer networkmanager
elif [[ $r == /run/resolvconf/* ]] || grep -qi resolvconf /etc/resolv.conf; then state_set writer resolvconf
fi
# The network configuration, for reset.
if is_rhel; then
	tar -C /etc/NetworkManager -cf "$LAB_STATE/nm.tar" system-connections conf.d
else
	tar -C /etc -cf "$LAB_STATE/netplan.tar" netplan
	[ -f /etc/systemd/resolved.conf ] && cp -a /etc/systemd/resolved.conf "$LAB_STATE/resolved.conf"
	ls /etc/systemd/resolved.conf.d >"$LAB_STATE/resolved-d" 2>/dev/null || true
	ls /etc/cloud/cloud.cfg.d >"$LAB_STATE/cloud-cfg" 2>/dev/null || true
fi
sed -i -E '/^[^#]*[[:space:]]fake\.example\.org([[:space:]]|$)/d' /etc/hosts
true
