has_live() { ip -o -4 addr show dev lab0 2>/dev/null | grep -qF " $1 "; }

task 1 "labtest resolves to 10.99.99.99 without DNS"
need "getent hosts labtest prints 10.99.99.99" 'getent hosts labtest | grep -q "^10\.99\.99\.99[[:space:]]"'
need "/etc/hosts has the line" 'grep -Eq "^10\.99\.99\.99[[:space:]].*\blabtest\b" /etc/hosts'

task 2 "Connection lab0 has 192.168.77.10/24 as well" rhel
if is_rhel; then
	need "connection lab0 has 192.168.77.10/24" 'nmcli -g ipv4.addresses connection show lab0 | grep -qF 192.168.77.10/24'
	need "connection lab0 keeps 192.168.76.1/24" 'nmcli -g ipv4.addresses connection show lab0 | grep -qF 192.168.76.1/24'
	need "lab0 has both addresses now (connection up)" 'has_live 192.168.77.10/24 && has_live 192.168.76.1/24'
fi

task 3 "lab0 has 192.168.77.10/24 from /etc/netplan/90-lab.yaml" debian
if is_debian; then
	need "/etc/netplan/90-lab.yaml exists" '[ -f /etc/netplan/90-lab.yaml ]'
	need "only root can read it (mode 600)" '[ "$(stat -c %a /etc/netplan/90-lab.yaml)" = 600 ]'
	need "it gives lab0 192.168.77.10/24" 'netplan get ethernets.lab0.addresses 2>/dev/null | grep -qF 192.168.77.10/24'
	need "lab0 has 192.168.77.10/24 now (applied)" 'has_live 192.168.77.10/24'
fi
