Z=$(state_get zone)
fw() { firewall-cmd --zone="$Z" "$@"; }
# Rich rules that accept SSH from a source address, now (or --permanent).
ssh_rules() { fw "$@" --list-rich-rules 2>/dev/null | grep -E 'source address="?[0-9.]+(/[0-9]+)?' | grep -E 'service name="?ssh"?|port port="?22"?' | grep -w accept; }
# Every established SSH client address falls in a rule's network.
clients_covered() {
	local nets
	nets=$(ssh_rules | sed -E 's/.*source address="?([0-9./]+)"?.*/\1/')
	ss -Htn state established '( sport = :22 )' | awk '{print $4}' | sed -E 's/:[0-9]+$//; s/^\[?::ffff://; s/\]$//' |
		python3 -c '
import ipaddress, sys
nets = [ipaddress.ip_network(n, strict=False) for n in sys.argv[1].split()]
for a in sys.stdin.read().split():
    try:
        ip = ipaddress.ip_address(a)
    except ValueError:
        continue
    if ip.is_loopback or ip.version != 4:
        continue
    if not any(ip in n for n in nets):
        sys.exit(1)' "$nets"
}
peer_ssh() { in_peer timeout 5 bash -c 'exec 3<>/dev/tcp/10.99.0.1/22; head -c 4 <&3' 2>/dev/null | grep -q SSH; }
peer_curl() {
	local i
	for i in 1 2 3 4 5; do
		in_peer curl -s --max-time 3 http://10.99.0.1:8080/ | grep -q "Lab httpd" && return 0
		sleep 2
	done
	return 1
}

task 1 "SSH allowed only from one network, with a rich rule"
need "firewalld is running" active firewalld
need "a rich rule accepts SSH from a network, now and permanently" '[ -n "$(ssh_rules)" ] && [ -n "$(ssh_rules --permanent)" ]'
need "the ssh service is out of the zone, now and permanently" '! fw --query-service=ssh && ! fw --permanent --query-service=ssh'
need "port 22 isn't open to everyone" '! fw --query-port=22/tcp'
need "your current SSH connections come from inside the rule's network" clients_covered
need "the peer (10.99.0.2) can't reach SSH" '! peer_ssh'

task 2 "TCP port 8080 forwarded to port 80"
need "httpd is running" active httpd
need "the zone forwards 8080/tcp to port 80, now and permanently" 'fw --list-forward-ports | grep -q "port=8080:proto=tcp:toport=80:" && fw --permanent --list-forward-ports | grep -q "port=8080:proto=tcp:toport=80:"'
need "curl http://10.99.0.1:8080/ from the peer reaches httpd" peer_curl

task 3 "Traffic from 192.168.50.0/24 goes to the internal zone"
need "the internal zone has source 192.168.50.0/24, now" 'firewall-cmd --zone=internal --list-sources | grep -qw "192\.168\.50\.0/24"'
need "and permanently" 'firewall-cmd --permanent --zone=internal --list-sources | grep -qw "192\.168\.50\.0/24"'
need "firewall-cmd --get-active-zones lists internal with it" 'firewall-cmd --get-active-zones | grep -A3 "^internal" | grep -q "192\.168\.50\.0/24"'
