# mbits: throughput from the peer to an iperf3 server on this VM, in Mbit/s.
mbits() {
	local srv=''
	if ! listening 5201 tcp; then iperf3 -s -1 -p 5201 >/dev/null 2>&1 & srv=$!; sleep 1; fi
	in_peer timeout 15 iperf3 -c 10.99.0.1 -t 2 -J 2>/dev/null |
		python3 -c 'import json, sys; print(int(json.load(sys.stdin)["end"]["sum_received"]["bits_per_second"] / 1e6))'
	[ -n "$srv" ] && kill $srv 2>/dev/null
	true
}
num() { answer "$1" | grep -oE '[0-9]+(\.[0-9]+)?' | head -1 | cut -d. -f1; }

task 1 "The disk writer's service named and stopped"
need "/root/lab-answers/1 names the service" 'answer 1 | grep -q log-shipper'
need "log-shipper is stopped and disabled" '! active log-shipper && ! enabled log-shipper'

task 2 "Latency to the peer measured, and the delay removed"
need "/root/lab-answers/2 has the average RTT you measured (70 to 150 ms)" 'n=$(num 2); [ -n "$n" ] && [ "$n" -ge 70 ] && [ "$n" -le 150 ]'
need "le-host has no delay (netem) any more" '! tc qdisc show dev le-host | grep -q netem'
need "ping to the peer takes under 20 ms" 'ping -c3 -i 0.2 -W2 10.99.0.2 | awk -F/ "/^rtt|^round-trip/ {exit !(\$5 < 20)}"'

task 3 "Throughput measured, and the limit removed"
need "/root/lab-answers/3 has the throughput you measured (20 to 60 Mbit/s)" 'n=$(num 3); [ -n "$n" ] && [ "$n" -ge 20 ] && [ "$n" -le 60 ]'
need "iperf3 is installed" 'command -v iperf3'
need "the peer's le-peer has no rate limit (tbf) any more" '! in_peer tc qdisc show dev le-peer | grep -q tbf'
need "iperf3 from the peer gets over 200 Mbit/s" 'n=$(mbits); [ -n "$n" ] && [ "$n" -gt 200 ]'
