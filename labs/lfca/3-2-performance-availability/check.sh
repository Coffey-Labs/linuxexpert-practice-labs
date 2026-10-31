# minutes N: the first number on line N of answer 1.
minutes() { sed -n "${1}p" /root/lab-answers/1 2>/dev/null | tr -d , | grep -Eo '[0-9]+(\.[0-9]+)?' | head -n1; }
# between N LOW HIGH: line N's number is in the range.
between() { local m; m=$(minutes "$1"); [ -n "$m" ] && awk -v m="$m" -v lo="$2" -v hi="$3" 'BEGIN { exit !(m >= lo && m <= hi) }'; }
T=$(nginx -T 2>/dev/null)
# Six requests to the load balancer reach both web servers.
both() {
	local i out=''
	for i in 1 2 3 4 5 6; do out+=$(curl -s --max-time 3 http://localhost/)$'\n'; done
	grep -q 'Web server one' <<<"$out" && grep -q 'Web server two' <<<"$out"
}

task 1 "Yearly downtime for 99.9%, 99.95% and 99.99% in /root/lab-answers/1"
need "line 1, 99.9%, is about 525.6 minutes" 'between 1 520 530'
need "line 2, 99.95%, is about 262.8 minutes" 'between 2 258 268'
need "line 3, 99.99%, is about 52.6 minutes" 'between 3 52 53.5'

task 2 "nginx on port 80 balances across both web servers"
need "nginx is installed" 'command -v nginx'
need "nginx starts at boot" enabled nginx
need "nginx is running" active nginx
need "an upstream block has a zone" 'grep -Eq "^[[:space:]]*zone[[:space:]]+[A-Za-z0-9_]+[[:space:]]+[0-9]+[kKmM]?[[:space:]]*;" <<<"$T"'
need "the upstream has both servers, 10.99.0.2:8081 and :8082" 'grep -Eq "^[[:space:]]*server[[:space:]]+(10\.99\.0\.2|peer):8081" <<<"$T" && grep -Eq "^[[:space:]]*server[[:space:]]+(10\.99\.0\.2|peer):8082" <<<"$T"'
need "a location uses proxy_pass" 'grep -Eq "^[[:space:]]*proxy_pass[[:space:]]+http://" <<<"$T"'
need "both web servers are running" 'active le-lab-backend1.service && active le-lab-backend2.service'
need "six requests to http://localhost/ get answers from both web servers" both

task 3 "Traffic moved when one server stopped" self
