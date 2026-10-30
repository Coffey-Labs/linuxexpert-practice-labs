# peer_get PORT: which back end answers the peer through PORT.
peer_get() { in_peer curl -s --max-time 4 "http://10.99.0.1:$1/" | sed -n 's/^Back end \([0-9]*\)$/\1/p'; }
# seen PORT N: the back ends that answered N requests.
seen() { local i; for i in $(seq "$2"); do peer_get "$1"; done | sort -u | tr '\n' ' '; }
# nginx keeps a round-robin position per worker: ask enough times.
W=$(pgrep -c -f 'nginx: worker')
N=$(( ${W:-0} * 2 + 2 ))
[ "$N" -le 40 ] || N=40
backends() { systemctl "$1" le-backend@8081 le-backend@8082; sleep 1; }

task 1 "nginx on port 80 in front of the back end"
need "nginx is running and enabled" 'active nginx && enabled nginx'
need "curl http://10.99.0.1/ from the peer returns a back end's page" '[ -n "$(peer_get 80)" ]'
if is_rhel && [ "$(state_get selinux)" = Enforcing ]; then
	need "SELinux is still enforcing" '[ "$(getenforce)" = Enforcing ]'
fi

task 2 "Port 80 balanced over 8081 and 8082, 8083 as backup"
need "requests to port 80 reach 8081 and 8082, not 8083" 's=$(seen 80 $N); [[ $s == *8081* && $s == *8082* && $s != *8083* ]]'
need "with 8081 and 8082 stopped, 8083 answers" 'backends stop; r=$(peer_get 80); backends start; [ "$r" = 8083 ]'

task 3 "Port 81 balanced, sticky by client address"
need "nginx's configuration has ip_hash or hash \$remote_addr" 'nginx -T 2>/dev/null | grep -Eq "^[[:space:]]*(ip_hash|hash[[:space:]]+\\\$remote_addr)"'
need "requests to port 81 from the peer always reach the same back end" 's=$(seen 81 $N); [ -n "$s" ] && [ "$(wc -w <<<"$s")" = 1 ]'

task 4 "HAProxy on port 8080 with health checks" debian
need "haproxy is running and enabled" 'active haproxy && enabled haproxy'
need "haproxy -c reports the configuration valid" 'haproxy -c -f /etc/haproxy/haproxy.cfg'
need "the servers have health checks" 'grep -Eq "^[[:space:]]*server[[:space:]].*[[:space:]]check([[:space:]]|$)" /etc/haproxy/haproxy.cfg'
need "requests to port 8080 reach 8081 and 8082, not 8083" 's=$(seen 8080 6); [[ $s == *8081* && $s == *8082* && $s != *8083* ]]'
need "a stopped back end leaves the rotation within a few seconds" 'systemctl stop le-backend@8081; sleep 8; s=$(for i in 1 2 3 4; do peer_get 8080 || echo x; done | tr "\n" " "); systemctl start le-backend@8081; [ "$s" = "8082 8082 8082 8082 " ]'

task 5 "The back ends behind port 80 get X-Forwarded-For"
need "the back end gets X-Forwarded-For with the peer's address" 'rm -f /run/le-backend/*.xff; b=$(peer_get 80); [ -n "$b" ] && grep -q "10\.99\.0\.2" /run/le-backend/$b.xff'
