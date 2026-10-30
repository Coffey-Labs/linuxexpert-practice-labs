# wait_listen PORT: give a running unit up to 15 seconds to start listening.
wait_listen() { local i; for i in $(seq 15); do listening "$1" tcp && return 0; sleep 1; done; return 1; }

task 1 "The peer reaches 198.51.100.9"
need "the peer can ping 198.51.100.9" 'in_peer ping -c1 -W2 198.51.100.9'
need "the peer's default route is via 10.99.0.1" 'in_peer ip route show default | grep -q "via 10\.99\.0\.1 "'
need "/etc/netns/lepeer/network sets the right gateway" '! grep -q "10\.99\.0\.254" /etc/netns/lepeer/network && grep -Eq "^[^#]*default via 10\.99\.0\.1([[:space:]]|$)" /etc/netns/lepeer/network'

task 2 "Names resolve on the peer"
need "getent hosts example.org works on the peer" 'in_peer getent hosts example.org'
need "/etc/netns/lepeer/resolv.conf has a working server" 'grep -Eq "^nameserver[[:space:]]+198\.51\.100\.53\b" /etc/netns/lepeer/resolv.conf'

task 3 "The web server answers the peer at http://10.99.0.1/"
need "le-lab-web is running" active le-lab-web
need "something listens on port 80" 'wait_listen 80'
need "curl http://10.99.0.1/ from the peer returns the page" 'in_peer curl -s --max-time 3 http://10.99.0.1/ | grep -q "Lab web server"'
need "le-lab-web is enabled" enabled le-lab-web

task 4 "DNS queries captured in /root/lab-answers/4"
need "/root/lab-answers/4 is a capture tcpdump can read" 'tcpdump -n -r /root/lab-answers/4'
need "the capture has a query for example.org" 'tcpdump -n -r /root/lab-answers/4 2>/dev/null | grep -Eq " (A|AAAA)\? example\.org\. "'
need "the capture has an answer" 'tcpdump -n -r /root/lab-answers/4 2>/dev/null | grep -Eq " [1-9][0-9]*/[0-9]+/[0-9]+ (A|AAAA|CNAME) "'

task 5 "The process on UDP port 8125, in /root/lab-answers/5"
need "the answer names the process" 'grep -qw metricsd /root/lab-answers/5'
need "the answer has both addresses" 'grep -qw "127\.0\.0\.1" /root/lab-answers/5 && grep -qw "10\.99\.0\.1" /root/lab-answers/5'
