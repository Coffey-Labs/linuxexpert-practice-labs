R=/root/fw/rules.v4
# rc URL: curl's exit code from the peer (28 is a timeout).
rc() { in_peer curl -s -o /dev/null --max-time 3 "$1"; echo $?; }
has() { grep -qE -- "$1" $R; }

task 1 "Stateful default-deny INPUT chain (saved in rules.v4), drops logged"
need "/root/fw/rules.v4 is iptables-save output without comments" 'grep -q "^\*filter" $R && grep -q "^COMMIT" $R && ! grep -q "^#" $R'
need "INPUT's policy is DROP" 'has "^:INPUT DROP"'
need "loopback is accepted" 'has "^-A INPUT -i lo -j ACCEPT"'
need "replies are accepted and invalid packets dropped" 'has "^-A INPUT .*--ctstate (RELATED,ESTABLISHED|ESTABLISHED,RELATED) -j ACCEPT" && has "^-A INPUT .*--ctstate INVALID -j DROP"'
need "new SSH connections are accepted" 'has "^-A INPUT .*--dport 22 .*-j ACCEPT"'
need "pings are accepted, at most 5 a second" 'has "^-A INPUT .*--icmp-type 8 .*--limit 5/sec .*-j ACCEPT"'
need "port 8080 is accepted from 10.99.0.2 only, with a comment" 'has "^-A INPUT -s 10\.99\.0\.2(/32)? .*--dport 8080 .*--comment .*-j ACCEPT"'
need "the rest is logged with FW-DROP: , 10 a minute" 'has "^-A INPUT .*--limit 10/min .*-j LOG --log-prefix \"FW-DROP: \""'
need "a drop of the peer's traffic was logged" 'journalctl -k --no-pager 2>/dev/null | grep "FW-DROP: " | grep -q "SRC=10\.99\.0\.2" || grep -hs "FW-DROP: " /var/log/messages /var/log/kern.log | grep -q "SRC=10\.99\.0\.2"'

task 2 "Port 8888 redirected to 8081, accepted only when redirected"
need "rules.v4 redirects 8888 on le-host to 8081" 'has "^-A PREROUTING -i le-host -p tcp( -m tcp)? --dport 8888 -j REDIRECT --to-ports 8081"'
need "rules.v4 accepts 8081 from the peer only with ctstate DNAT" 'has "^-A INPUT -s 10\.99\.0\.2(/32)? .*--dport 8081 .*--ctstate DNAT -j ACCEPT"'

task 3 "An IP set blocklist, matched by the second INPUT rule"
need "rules.v4 drops members of blocklist, second in INPUT" '[ "$(grep "^-A INPUT" $R | sed -n 2p)" = "-A INPUT -m set --match-set blocklist src -j DROP" ]'

task 4 "Rules saved in /root/fw/rules.v4"
need "rules.v4 has the filter and nat tables" 'grep -q "^\*filter" $R && grep -q "^\*nat" $R'

task 5 "nftables table inet lab, the peer removed from web_clients"
need "/root/fw/lab.nft is a valid nftables file with table inet lab" 'nft -c -f /root/fw/lab.nft && grep -Eq "table inet lab" /root/fw/lab.nft'
need "lab.nft puts the peer in web_clients" 'grep -A4 "set web_clients" /root/fw/lab.nft | grep -q "10\.99\.0\.2"'
need "the iptables rules are cleared, INPUT accepts" '! iptables -S INPUT 2>/dev/null | grep -q "^-A" && iptables -S INPUT 2>/dev/null | grep -q "^-P INPUT ACCEPT" && ! iptables -t nat -S PREROUTING 2>/dev/null | grep -q "^-A"'
need "the IP set is gone" '! ipset list blocklist >/dev/null 2>&1'
need "table inet lab is loaded with an input chain, policy drop" 'nft list table inet lab 2>/dev/null | grep -q "hook input.*policy drop"'
need "it logs with NFT-DROP: " 'nft list table inet lab | grep -q "log prefix \"NFT-DROP: \""'
need "web_clients is an ipv4_addr set without the peer now" 'nft list set inet lab web_clients | grep -q "type ipv4_addr" && ! nft list set inet lab web_clients | grep -q "10\.99\.0\.2"'
need "the peer can still ping and reach SSH" 'in_peer ping -c1 -W2 10.99.0.1 >/dev/null && in_peer timeout 4 bash -c "</dev/tcp/10.99.0.1/22"'
need "port 8080 is dropped for the peer" '[ "$(rc http://10.99.0.1:8080/)" = 28 ]'
need "port 8081 is dropped for the peer" '[ "$(rc http://10.99.0.1:8081/)" = 28 ]'
