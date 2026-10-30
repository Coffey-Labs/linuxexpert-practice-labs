IF=$(state_get if)
# The peer's second address goes at every reboot.
ip -n lepeer addr add 10.99.0.3/24 dev le-peer 2>/dev/null
# from ADDRESS PORT: curl's exit code from the peer's ADDRESS (0 when it works).
from() { in_peer curl -s -o /dev/null --max-time 4 --interface "$1" "http://10.99.0.1:$2/"; echo $?; }
if is_rhel && systemctl is-active --quiet firewalld; then
	Z=$(firewall-cmd --get-zone-of-interface="$IF" 2>/dev/null || firewall-cmd --get-default-zone)
fi
fw() { firewall-cmd "$@" --zone="$Z"; }

task 1 "firewalld allows HTTP permanently" rhel
need "firewalld is running and enabled" 'active firewalld && enabled firewalld'
need "http is allowed in the permanent configuration" 'fw --permanent --query-service=http'
need "http is allowed now" 'fw --query-service=http'

task 2 "8080/tcp allowed only from 10.99.0.2, with a rich rule" rhel
need "a rich rule allows 8080/tcp from 10.99.0.2, now and permanently" 'for p in "" --permanent; do fw $p --list-rich-rules | grep -E "10\.99\.0\.2(/32)?\"" | grep "8080" | grep -q accept || exit 1; done'
need "8080/tcp isn't open to everyone" '! fw --query-port=8080/tcp && ! fw --permanent --query-port=8080/tcp'
need "SSH is still allowed" 'fw --query-service=ssh || fw --query-port=22/tcp'
need "port 8080 answers 10.99.0.2" '[ "$(from 10.99.0.2 8080)" = 0 ]'
need "port 8080 is blocked from 10.99.0.3" '[ "$(from 10.99.0.3 8080)" != 0 ]'

task 3 "ufw on, allowing OpenSSH" debian
need "ufw is active" 'ufw status | grep -q "Status: active"'
need "ufw allows SSH" 'ufw status | grep -Eq "^(22(/tcp)?|OpenSSH)[[:space:]].*ALLOW"'
need "incoming traffic is denied by default" 'ufw status verbose | grep -Eq "Default: (deny|reject) \(incoming\)"'

task 4 "9000/tcp allowed only from 10.99.0.2" debian
need "a ufw rule allows 9000/tcp from 10.99.0.2" 'ufw status | grep -E "^9000(/tcp)?[[:space:]].*ALLOW.*10\.99\.0\.2([[:space:]]|$)"'
need "ufw doesn't allow 9000 from anywhere" '! ufw status | grep -E "^9000(/tcp)?[[:space:]].*ALLOW.*Anywhere"'
need "port 9000 answers 10.99.0.2" '[ "$(from 10.99.0.2 9000)" = 0 ]'
need "port 9000 is blocked from 10.99.0.3" '[ "$(from 10.99.0.3 9000)" != 0 ]'
