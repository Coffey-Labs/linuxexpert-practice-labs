SNORT=(snort -T -c /etc/snort/snort.conf -i le-host -S "HOME_NET=[10.99.0.0/24]")
LR=/etc/snort/rules/local.rules

task 1 "Local Snort rules 1000001 (ping) and 1000002 (/lab-admin)"
need "Snort is installed" 'command -v snort'
need "local.rules has an ICMP type 8 rule with sid 1000001" 'grep -Ev "^[[:space:]]*#" $LR | grep "sid:1000001;" | grep -q "itype:8"'
need "local.rules has a /lab-admin rule for port 8080 with sid 1000002" 'grep -Ev "^[[:space:]]*#" $LR | grep "sid:1000002;" | grep "/lab-admin" | grep -q 8080'
need "snort -T validates the configuration on le-host" 'timeout 120 "${SNORT[@]}" 2>&1 | grep -q "successfully validated"'

task 2 "Alerts by hand in /root/snort-console.txt"
need "/root/snort-console.txt has an alert from rule 1000001" 'grep -q "\[1:1000001:" /root/snort-console.txt'
need "it has an alert from rule 1000002" 'grep -q "\[1:1000002:" /root/snort-console.txt'
need "it has the Xmas scan alert, rule 1228" 'grep -q "\[1:1228:" /root/snort-console.txt'
need "the alerts came from the peer" 'grep "\[1:1000001:" /root/snort-console.txt | grep -q "10\.99\.0\.2"'

task 3 "The snort service watches le-host for 10.99.0.0/24"
need "snort is running" 'active snort && pgrep -x snort'
need "it watches le-host" 'ps -o args= -C snort | grep -q -- "-i le-host"'
need "its home network is 10.99.0.0/24" 'ps -o args= -C snort | grep -q "HOME_NET=\[10.99.0.0/24\]"'
need "it starts at boot" 'grep -Eq "^DEBIAN_SNORT_STARTUP=\"?boot" /etc/snort/snort.debian.conf && enabled snort'
need "a ping from the peer lands in snort.alert.fast" 'n=$(grep -c 1000001 /var/log/snort/snort.alert.fast 2>/dev/null); in_peer ping -c 3 -i 0.3 10.99.0.1 >/dev/null; for i in $(seq 15); do [ "$(grep -c 1000001 /var/log/snort/snort.alert.fast 2>/dev/null)" -gt "${n:-0}" ] && exit 0; sleep 1; done; exit 1'

task 4 "ntopng watches le-host on port 3000; iftop is installed"
need "ntopng is running and enabled" 'active ntopng && enabled ntopng'
need "/etc/ntopng.conf watches le-host" 'grep -Eq "^-i=le-host[[:space:]]*$" /etc/ntopng.conf'
need "ntopng answers on port 3000" 'for i in $(seq 15); do curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://127.0.0.1:3000/ | grep -Eq "^(200|302)$" && exit 0; sleep 1; done; exit 1'
need "iftop is installed" 'command -v iftop'
