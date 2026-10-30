# The names ss shows for whatever listens on port 22.
port22=$(ss -Htlnp 'sport = :22' | grep -o '(("[^"]*"\|,("[^"]*"' | grep -o '"[^"]*"' | tr -d '"' | sort -u)
# reach_9000: the peer opens a TCP connection to 10.99.0.1:9000 (15 seconds).
reach_9000() { local i; for i in $(seq 5); do in_peer timeout 3 bash -c '</dev/tcp/10.99.0.1/9000' 2>/dev/null && return 0; sleep 1; done; return 1; }

task 1 "The process on port 22 in /root/lab-answers/1; netstat installed"
need "the answer is a process that listens on port 22 ($(echo $port22 | tr " " /))" '[ -n "$(answer 1)" ] && grep -qx "$(answer 1)" <<<"$port22"'
need "netstat is installed" 'command -v netstat'

task 2 "A netcat listener on 9000 that the peer can reach"
need "nc is installed" 'command -v nc'
need "something listens on TCP port 9000" 'listening 9000 tcp'
need "the peer can connect to 10.99.0.1:9000 (open the firewall if one is running)" reach_9000

task 3 "The link to the peer fixed; the interface named in /root/lab-answers/3"
need "le-host is up" 'ip link show le-host | grep -q "state UP"'
need "this VM can ping the peer" 'ping -c1 -W2 10.99.0.2'
need "the answer is le-host" '[ "$(answer 3)" = le-host ]'
