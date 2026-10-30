gw=$(ip -4 route show default | awk '{print $3; exit}')
# reach PORT: the peer can open a TCP connection to PORT here. If nothing
# listens there, a listener runs for a moment so that the firewall is tested.
reach() {
	local pid='' ok=1
	if ! listening "$1" tcp; then
		python3 -c 'import socket,sys,time
s=socket.socket(); s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("0.0.0.0", int(sys.argv[1]))); s.listen(5); time.sleep(12)' "$1" &
		pid=$!
		for i in 1 2 3 4 5 6 7 8 9 10; do listening "$1" tcp && break; sleep 0.3; done
	fi
	in_peer timeout 6 bash -c "</dev/tcp/10.99.0.1/$1" && ok=0
	[ -n "$pid" ] && kill "$pid" 2>/dev/null
	return $ok
}

task 1 "The default gateway's address"
need "/root/lab-answers/1 has the default gateway, $gw" '[ "$(answer 1)" = "$gw" ]'

task 2 "The status line of https://www.kernel.org"
need "/root/lab-answers/2 has an HTTP status line" 'answer 2 | grep -Eq "^http/[0-9.]+ [1-5][0-9][0-9]"'

task 3 "DNS traffic captured with tcpdump" self

task 4 "iperf3 and nc installed; the peer reaches ports 9000 and 5201 here"
need "iperf3 is installed" 'command -v iperf3'
need "nc is installed" 'command -v nc'
need "the peer can connect to port 9000/tcp here" 'reach 9000'
need "the peer can connect to port 5201/tcp here" 'reach 5201'
