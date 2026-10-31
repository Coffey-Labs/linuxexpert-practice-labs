# The peer's second address, in case something took it away.
ip -n lepeer addr add 10.99.0.3/24 dev le-peer 2>/dev/null
# from ADDRESS: curl's exit code for s1's web server from the peer's
# ADDRESS (0 works, 28 timed out).
from() { in_peer curl -s -o /dev/null --max-time 4 --interface "$1" http://10.99.0.1/; echo $?; }
S=$(ufw status 2>/dev/null)
# ufw.log since the lab started.
newlog() {
	local n; n=$(state_get ufwlog-size); n=${n:-0}
	[ "$(stat -c %s /var/log/ufw.log 2>/dev/null || echo 0)" -ge "$n" ] || n=0
	tail -c +$((n + 1)) /var/log/ufw.log 2>/dev/null
}
P=$(in_peer iptables -S INPUT 2>/dev/null)

task 1 "ufw on, denying incoming, allowing SSH from anywhere"
need "ufw is active" 'grep -q "Status: active" <<<"$S"'
need "ufw starts at boot" 'grep -Eq "^ENABLED=yes" /etc/ufw/ufw.conf'
need "incoming traffic is denied by default" 'ufw status verbose | grep -Eq "Default: (deny|reject) \(incoming\)"'
need "SSH is allowed from anywhere" 'grep -Eq "^(22(/tcp)?|OpenSSH)( \(OpenSSH\))?[[:space:]]+(ALLOW|LIMIT)( IN)?[[:space:]]+Anywhere" <<<"$S"'
need "HTTP from 10.99.0.3 (any other machine) times out" '[ "$(from 10.99.0.3)" = 28 ]'

task 2 "No HTTP rule; SSH rate-limited, and the limit seen in ufw.log"
need "ufw is active" 'grep -q "Status: active" <<<"$S"'
need "ufw has no rule for port 80" '! grep -Eq "^(80|80/tcp|WWW|Apache|Nginx)[[:space:]( ]" <<<"$S"'
need "SSH is LIMIT" 'grep -Eq "^(22(/tcp)?|OpenSSH)( \(OpenSSH\))?[[:space:]]+LIMIT" <<<"$S"'
need "HTTP from the peer now times out" '[ "$(from 10.99.0.2)" = 28 ]'
need "/var/log/ufw.log has [UFW LIMIT BLOCK] lines for the peer's SSH" 'newlog | grep "\[UFW LIMIT BLOCK\]" | grep "SRC=10\.99\.0\.2 " | grep -q "DPT=22 "'

task 3 "The peer's iptables: loopback, SSH, ping and replies only, at boot"
need "/etc/netns/lepeer/iptables.rules holds iptables rules" 'in_peer iptables-restore --test /etc/netns/lepeer/iptables.rules'
need "le-lab-peer-iptables.service is enabled" enabled le-lab-peer-iptables.service
need "the peer's INPUT policy is DROP" 'grep -qx -- "-P INPUT DROP" <<<"$P"'
need "the peer drops its test web server's port 8000" '[ "$(curl -s -o /dev/null --max-time 4 http://10.99.0.2:8000/; echo $?)" = 28 ]'
need "ping -c1 10.99.0.2 works" 'ping -c1 -W2 10.99.0.2'
need "the peer answers SSH" 'timeout 8 ssh-keyscan -T 5 10.99.0.2 2>/dev/null | grep -q .'
need "the peer reaches its own services over loopback" 'in_peer curl -s --max-time 3 http://10.99.0.2:8000/ | grep -q "Peer test page"'
# From the second address: task 2's rate limit counts per address.
need "the peer gets replies to its own connections" 'in_peer nc -z -w 4 -s 10.99.0.3 10.99.0.1 22'
