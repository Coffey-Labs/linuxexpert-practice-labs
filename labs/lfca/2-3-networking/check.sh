IF=$(state_get if)
A=/root/lab-answers
# has N VALUE: a line of answer N is VALUE (spaces ignored).
has() { sed 's/^[[:space:]]*//; s/[[:space:]]*$//' "$A/$1" 2>/dev/null | grep -qxF -- "$2"; }
hasre() { sed 's/^[[:space:]]*//; s/[[:space:]]*$//' "$A/$1" 2>/dev/null | grep -qxE -- "$2"; }
ADDR=$(ip -4 -o addr show dev "$IF" scope global | awk '{print $4; exit}')
GW=$(ip -4 route show default | awk '{print $3; exit}')
SSHOPT=(-o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o PreferredAuthentications=publickey)

# The firewall: firewalld if it's running, otherwise ufw.
fwd=''; active firewalld && fwd=1
ufw_on() { command -v ufw >/dev/null && ufw status | grep -q 'Status: active'; }
zones() { { firewall-cmd --get-zone-of-interface="$IF" 2>/dev/null || firewall-cmd --get-default-zone; firewall-cmd --get-default-zone; } | sort -u; }
only_ssh() {
	local z p
	if [ -n "$fwd" ]; then
		for z in $(zones); do
			for p in "" --permanent; do
				firewall-cmd $p --zone="$z" --list-services | tr ' ' '\n' | grep -Evx 'ssh|dhcpv6-client|' && return 1
				[ -z "$(firewall-cmd $p --zone="$z" --list-ports)" ] || return 1
				[ "$(firewall-cmd $p --zone="$z" --get-target)" != ACCEPT ] || return 1
			done
		done
		return 0
	fi
	! ufw status | grep ALLOW | grep -v FWD | grep -Evq '^(22(/tcp)?|OpenSSH)[[:space:]]' &&
		ufw status verbose | grep -Eq 'Default: (deny|reject) \(incoming\)'
}
peer_ssh() { in_peer timeout 5 bash -c 'exec 3<>/dev/tcp/10.99.0.1/22; head -c 4 <&3' 2>/dev/null | grep -q SSH; }
peer_web() { in_peer curl -s --max-time 5 http://10.99.0.1:8080/ | grep -q "Lab web server"; }

task 1 "Address with prefix and default gateway in /root/lab-answers/1"
need "the answer has the address with its prefix, $ADDR" 'has 1 "$ADDR"'
need "the answer has the default gateway, $GW" 'has 1 "$GW"'

task 2 "10.20.30.77/26 worked out in /root/lab-answers/2"
need "the answer has the network address" 'hasre 2 "10\.20\.30\.64(/26)?"'
need "the answer has the broadcast address" 'hasre 2 "10\.20\.30\.127(/26)?"'
need "the answer has the first usable address" 'hasre 2 "10\.20\.30\.65(/26)?"'
need "the answer has the last usable address" 'hasre 2 "10\.20\.30\.126(/26)?"'

task 3 "The program on TCP port 8080 in /root/lab-answers/3"
need "the answer names the program listening on 8080" '[ -n "$(answer 3)" ] && ss -Htlpn "sport = :8080" | grep -qF "\"$(answer 3)"'

task 4 "dig installed; a domain looked up"
need "dig is installed" 'command -v dig'
need "/root/lab-answers/4 is a domain with an A record" '[ -n "$(answer 4)" ] && dig +short +time=3 +tries=2 A "$(answer 4)" | grep -Eq "^[0-9.]+$"'

task 5 "ssh alice@localhost logs root in with a key"
need "root has a key pair" 'ls /root/.ssh/id_*.pub'
need "ssh alice@localhost logs in with the key, without a password" 'timeout 15 ssh "${SSHOPT[@]}" alice@localhost id -un </dev/null | grep -qx alice'

task 6 "The firewall is on and allows only SSH"
need "firewalld or ufw is on" '[ -n "$fwd" ] || ufw_on'
need "it's on at boot" 'if [ -n "$fwd" ]; then enabled firewalld; else grep -qx "ENABLED=yes" /etc/ufw/ufw.conf; fi'
need "it allows only SSH in, now and permanently" only_ssh
need "the web server on 8080 is still running" active le-lab-app.service
need "the peer can't reach port 8080" '! peer_web'
need "the peer can still reach SSH" peer_ssh
