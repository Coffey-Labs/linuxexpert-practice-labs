IF=$(ip -4 route show default | awk '{for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit }}')
if is_rhel; then
	MAINFILE=$(nmcli -t -f DEVICE,FILENAME connection show --active 2>/dev/null | awk -F: -v d="$IF" '$1 == d {print $2; exit}')
	prof() { nmcli -g "$1" connection show lab-net 2>/dev/null | tr -d '\\'; }
fi
# The netplan file in answer 1 sets up the main interface (by name or MAC).
netplan_main_ok() {
	local f mac
	f=$(head -n1 /root/lab-answers/1 2>/dev/null)
	case $f in /etc/netplan/*.yaml | /run/netplan/*.yaml | /lib/netplan/*.yaml | /usr/lib/netplan/*.yaml) ;; *) return 1 ;; esac
	[ -f "$f" ] && [ -n "$IF" ] || return 1
	mac=$(cat "/sys/class/net/$IF/address" 2>/dev/null)
	grep -qwF "$IF" "$f" || { [ -n "$mac" ] && grep -qiF "$mac" "$f"; }
}

task 1 "The main interface's configuration file in /root/lab-answers/1"
if is_rhel; then
	need "the answer is the file of $IF's active connection" '[ -n "$MAINFILE" ] && [ "$(head -n1 /root/lab-answers/1)" = "$MAINFILE" ]'
else
	need "the answer is the netplan file that sets up $IF" netplan_main_ok
fi

task 2 "le-lan has the static address 10.98.0.10/24, persistently"
if is_rhel; then
	need "lab-net's IPv4 method is manual" '[ "$(prof ipv4.method)" = manual ]'
	need "lab-net has 10.98.0.10/24" 'prof ipv4.addresses | tr "," "\n" | tr -d " " | grep -qx 10.98.0.10/24'
else
	need "a file in /etc/netplan/ gives le-lan 10.98.0.10/24" 'grep -qs le-lan /etc/netplan/*.yaml && netplan get ethernets.le-lan.addresses 2>/dev/null | grep -qF 10.98.0.10/24'
fi
need "le-lan has 10.98.0.10/24, not from DHCP" 'ip -o -4 addr show dev le-lan | grep -F " 10.98.0.10/24 " | grep -vq dynamic'
need "the route to 10.98.0.0/24 goes out le-lan" 'ip route get 10.98.0.1 | grep -q "dev le-lan"'
need "10.98.0.1 answers ping" 'ping -c1 -W2 10.98.0.1'

task 3 "Host name lab2.example.net"
need "hostname prints lab2.example.net" '[ "$(hostname)" = lab2.example.net ]'
need "/etc/hostname has lab2.example.net" 'grep -qx lab2.example.net /etc/hostname'

task 4 "files.lab.example is 10.99.0.2, from /etc/hosts"
need "/etc/hosts has files.lab.example for 10.99.0.2" 'grep -Eq "^10\.99\.0\.2[[:space:]]+(.*[[:space:]])?files\.lab\.example([[:space:]]|$)" /etc/hosts'
need "getent hosts files.lab.example gives 10.99.0.2" 'getent hosts files.lab.example | grep -q "^10\.99\.0\.2 "'
need "ping files.lab.example works" 'ping -c1 -W2 files.lab.example'
