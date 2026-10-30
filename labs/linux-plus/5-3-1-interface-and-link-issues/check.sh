MAC=$(state_get peer-mac)

task 1 "le-host up, and the peer reachable"
need "le-host is up" 'ip -o link show le-host | grep -q "<[^>]*\bUP\b"'
need "this VM can ping 10.99.0.2" 'ping -c1 -W2 10.99.0.2'

task 2 "The path MTU to the peer"
# veth lets frames 4 bytes over the MTU through, so 1400 to 1404 counts.
need "/root/lab-answers/2 has the path MTU" 'n=$(answer 2 | tr -dc 0-9); [ -n "$n" ] && [ "$n" -ge 1400 ] && [ "$n" -le 1404 ]'

task 3 "Dummy interface lab0, MTU 1400, link down"
need "lab0 exists and is a dummy interface" 'ip -d link show lab0 | grep -qw dummy'
need "it has 192.0.2.10/24" 'ip -4 -o addr show dev lab0 | grep -q " 192\.0\.2\.10/24 "'
need "its MTU is 1400" 'ip -o link show lab0 | grep -q " mtu 1400 "'
need "its link is down" '! ip -o link show lab0 | grep -q "<[^>]*\bUP\b"'

task 4 "The host that already uses 10.99.0.5"
need "/root/lab-answers/4 has its MAC address" '[ -n "$MAC" ] && grep -qi "$MAC" /root/lab-answers/4'
