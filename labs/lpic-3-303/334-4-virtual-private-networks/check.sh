pping() { in_peer ping -c 2 -W 2 "$1" >/dev/null 2>&1; }
# retry N CMD: CMD succeeds within N tries a second apart.
retry() { local n=$1 i; shift; for i in $(seq "$n"); do "$@" && return 0; sleep 1; done; return 1; }

task 1 "WireGuard wg0, 10.40.0.1/24, and the peer as 10.40.0.2"
need "wg-quick@wg0 is running and enabled" 'active wg-quick@wg0 && enabled wg-quick@wg0'
need "wg0 has 10.40.0.1/24 and listens on 51820" 'ip -4 -o addr show wg0 | grep -q "10\.40\.0\.1/24" && [ "$(wg show wg0 listen-port)" = 51820 ]'
need "/etc/wireguard/wg0.conf is readable by root only" '[ "$(stat -c %a /etc/wireguard/wg0.conf)" = 600 ]'
need "wg0 allows one peer as 10.40.0.2/32" 'wg show wg0 allowed-ips | grep -q "10\.40\.0\.2/32"'
need "le-lab-peer-wg.service is running and enabled" 'active le-lab-peer-wg.service && enabled le-lab-peer-wg.service'
need "the peer reaches 10.40.0.1 through the tunnel" 'retry 10 pping 10.40.0.1'
need "the two ends have shaken hands" '[ "$(wg show wg0 latest-handshakes | awk "{print \$2}" | sort -n | tail -1)" -gt 0 ]'

task 2 "OpenVPN PKI in /root/vpn/ca and openvpn-server@lab"
need "the PKI has a CA, a server certificate and a client certificate peer" 'P=/root/vpn/ca/pki; [ -f $P/ca.crt ] && openssl verify -CAfile $P/ca.crt $P/issued/server.crt $P/issued/peer.crt'
need "server.crt is for a server" 'openssl x509 -in /root/vpn/ca/pki/issued/server.crt -noout -ext extendedKeyUsage | grep -q "TLS Web Server Authentication"'
need "openvpn-server@lab is running and enabled" 'active openvpn-server@lab && enabled openvpn-server@lab'
need "it listens on UDP 1194" 'listening 1194 udp'
need "its tunnel has 10.8.0.1/24" 'ip -4 -o addr | grep -q "inet 10\.8\.0\.1/24"'
need "it uses tls-crypt, no DH, and drops to nobody" 'C=/etc/openvpn/server/lab.conf; grep -Eq "^tls-crypt " $C && grep -Eq "^dh none" $C && grep -Eq "^user nobody" $C'

task 3 "The peer's inline client configuration reaches 10.8.0.1"
need "/etc/netns/lepeer/openvpn/lab.conf has the CA, certificate, key and tls-crypt key inline" 'C=/etc/netns/lepeer/openvpn/lab.conf; for b in ca cert key tls-crypt; do grep -q "^<$b>" $C && grep -q "^</$b>" $C || exit 1; done'
need "it checks the server's certificate type" 'grep -Eq "^remote-cert-tls server" /etc/netns/lepeer/openvpn/lab.conf'
need "le-lab-peer-openvpn.service is running and enabled" 'active le-lab-peer-openvpn.service && enabled le-lab-peer-openvpn.service'
need "the peer reaches 10.8.0.1 through the tunnel" 'retry 15 pping 10.8.0.1'

task 4 "IPsec: traffic with the peer travels as ESP"
need "strongswan is running" 'active strongswan'
need "a file in /etc/swanctl/conf.d sets up this side" 'grep -rqs "remote_addrs *= *10\.99\.0\.2" /etc/swanctl/conf.d'
need "a ping to the peer gets through" 'retry 5 ping -c 1 -W 2 10.99.0.2 >/dev/null'
need "an IKE SA with the peer is established" 'retry 10 sh -c "swanctl --list-sas 2>/dev/null | grep -q ESTABLISHED"'
need "a transport-mode child SA is installed" 'swanctl --list-sas 2>/dev/null | grep -q "INSTALLED, TRANSPORT"'
need "pings to the peer are counted on the ESP SA" 'b=$(ip -s xfrm state | awk "/dst 10.99.0.2/ { f = 1 } f && /lifetime current:/ { getline; print \$1; exit }"); ping -c 3 -i 0.3 10.99.0.2 >/dev/null; a=$(ip -s xfrm state | awk "/dst 10.99.0.2/ { f = 1 } f && /lifetime current:/ { getline; print \$1; exit }"); [ "${a%(*}" -gt "${b%(*}" ]'
