# The main interface, its address, gateway and DNS server, as they are now.
IF=$(ip -4 route show default | awk '{for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit }}')
[ -n "$IF" ] || die "no default route; this lab needs a working network"
GW=$(ip -4 route show default dev "$IF" | awk '{print $3; exit}')
ADDR=$(ip -4 -o addr show dev "$IF" scope global | awk '{print $4; exit}')
if is_rhel; then
	DNS=$(nmcli -g IP4.DNS device show "$IF" 2>/dev/null | head -n1 | cut -d' ' -f1 | cut -d'|' -f1)
else
	DNS=$(resolvectl dns "$IF" 2>/dev/null | sed 's/.*://' | awk '{print $1}')
fi
[ -n "$DNS" ] || DNS=$(awk '$1 == "nameserver" && $2 !~ /^127\./ {print $2; exit}' /etc/resolv.conf)
[ -n "$DNS" ] || DNS=$GW
state_set if "$IF"; state_set gw "$GW"; state_set addr "$ADDR"; state_set dns "$DNS"
state_set hostname "$(hostname)"
cat >/root/lab-network.txt <<X
Main interface: $IF
IPv4 address:   $ADDR
Gateway:        $GW
DNS server:     $DNS
X

# Save the network configuration so reset can put it back.
if is_rhel; then
	tar -C /etc/NetworkManager -cf "$LAB_STATE/nm.tar" system-connections
	con=$(nmcli -g GENERAL.CONNECTION device show "$IF")
	[ -n "$con" ] && state_set con-uuid "$(nmcli -g connection.uuid connection show "$con")"
else
	tar -C /etc -cf "$LAB_STATE/netplan.tar" netplan
	ls /etc/cloud/cloud.cfg.d >"$LAB_STATE/cloud-cfg" 2>/dev/null || true
	ls /etc/systemd/resolved.conf.d >"$LAB_STATE/resolved-d" 2>/dev/null || true
fi

# A fresh start for tasks 4 and 5.
[ "$(hostname)" != lab1.example.org ] || hostnamectl set-hostname lab-vm
sed -i -E '/^[^#]*[[:space:]]db1([[:space:]]|$)/d' /etc/hosts
