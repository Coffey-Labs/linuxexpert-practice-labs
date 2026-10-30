IF=$(state_get if)
# curl_rc URL: curl's exit code from the peer (28 is a timeout).
curl_rc() { in_peer curl -s -o /dev/null --max-time 5 "$1"; echo $?; }
if is_rhel && systemctl is-active --quiet firewalld; then
	Z=$(firewall-cmd --get-zone-of-interface="$IF" 2>/dev/null || firewall-cmd --get-default-zone)
fi
fw() { firewall-cmd "$@" --zone="$Z"; }

task 1 "firewalld: http and https, no cockpit, 5432/tcp from 192.168.122.0/24" rhel
need "firewalld is running and enabled" 'active firewalld && enabled firewalld'
need "http and https are allowed, now and permanently" 'for p in "" --permanent; do fw $p --query-service=http && fw $p --query-service=https || exit 1; done'
need "cockpit is removed, now and permanently" '! fw --query-service=cockpit && ! fw --permanent --query-service=cockpit'
need "a rich rule allows 5432/tcp from 192.168.122.0/24, now and permanently" 'for p in "" --permanent; do fw $p --list-rich-rules | grep "192\.168\.122\.0/24" | grep -E "5432|postgresql" | grep -q accept || exit 1; done'
need "5432/tcp isn't open to everyone" '! fw --query-port=5432/tcp && ! fw --query-service=postgresql'
need "SSH is still allowed" 'fw --query-service=ssh || fw --query-port=22/tcp'

task 2 "ufw on, allowing only SSH and port 80" debian
need "ufw is active" 'ufw status | grep -q "Status: active"'
need "incoming traffic is denied by default" 'ufw status verbose | grep -Eq "Default: (deny|reject) \(incoming\)"'
need "ufw allows SSH" 'ufw status | grep -Eq "^(22(/tcp)?|OpenSSH)[[:space:]].*ALLOW"'
need "ufw allows port 80" 'ufw status | grep -Eq "^80(/tcp)?[[:space:]].*ALLOW"'
need "ufw allows nothing else in" '! ufw status | grep ALLOW | grep -v FWD | grep -Evq "^(22(/tcp)?|OpenSSH|80(/tcp)?)[[:space:]]"'
need "port 8080 times out from the peer" '[ "$(curl_rc http://10.99.0.1:8080/)" = 28 ]'
need "port 80 doesn't time out from the peer" '[ "$(curl_rc http://10.99.0.1/)" != 28 ]'

task 3 "The peer drops all incoming but replies, loopback, ping and SSH"
need "/etc/netns/lepeer/nftables.conf is a valid nftables file" 'in_peer nft -c -f /etc/netns/lepeer/nftables.conf'
need "le-lab-peer-nftables.service is enabled" enabled le-lab-peer-nftables.service
need "the peer's input chain drops by default" 'in_peer nft list ruleset | grep -Eq "hook input .*policy drop"'
need "the peer drops its test web server's port 8000" '[ "$(curl -s -o /dev/null --max-time 4 http://10.99.0.2:8000/; echo $?)" = 28 ]'
need "the peer answers ping" 'ping -c1 -W2 10.99.0.2'
need "the peer answers SSH" 'timeout 8 ssh-keyscan -T 5 10.99.0.2 2>/dev/null | grep -q .'
need "the peer reaches its own services over loopback" 'in_peer curl -s --max-time 3 http://10.99.0.2:8000/ | grep -q "Peer test page"'
need "the peer gets replies to its own connections" 'in_peer timeout 4 bash -c "</dev/tcp/10.99.0.1/22"'

task 4 "Port 80 redirected to 8080"
need "curl http://10.99.0.1/ from the peer reaches the service on 8080" 'in_peer curl -s --max-time 5 http://10.99.0.1/ | grep -q "Lab app on port 8080"'
if is_rhel; then
	need "the redirect is in firewalld's permanent configuration" 'grep -rqs "to-\?port=\"8080\"" /etc/firewalld/zones /etc/firewalld/policies'
else
	need "the redirect is in a configuration loaded at boot" 'grep -rqsE "(REDIRECT|DNAT|redirect|dnat).*8080" /etc/ufw /etc/nftables.conf /etc/nftables.d /etc/iptables'
fi

task 5 "This VM is the peer's NAT gateway"
need "the peer can ping 9.9.9.9" 'in_peer ping -c1 -W3 9.9.9.9'
if is_rhel && systemctl is-active --quiet firewalld; then
	need "masquerading is in firewalld's permanent configuration" 'grep -rqs "<masquerade" /etc/firewalld/zones /etc/firewalld/policies'
else
	need "forwarding is on at boot" 'grep -rqsE "^[[:space:]]*net[./]ipv4[./]ip_forward[[:space:]]*=[[:space:]]*1" /etc/sysctl.conf /etc/sysctl.d /etc/ufw/sysctl.conf'
	need "masquerading is in a configuration loaded at boot" 'grep -rqsE "MASQUERADE|masquerade" /etc/ufw/before.rules /etc/nftables.conf /etc/nftables.d /etc/iptables'
fi
