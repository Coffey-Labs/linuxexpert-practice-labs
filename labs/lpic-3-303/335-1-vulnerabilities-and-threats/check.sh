T=/root/threats
LONG=$(printf 'A%.0s' {1..64})
INJECT="x' OR '1'='1"
# names: the names in users.db's users table, sorted.
names() { python3 -c 'import sqlite3, sys; print(" ".join(sorted(str(r[0]) for r in sqlite3.connect("file:" + sys.argv[1] + "?mode=ro", uri=True).execute("SELECT name FROM users"))))' "$T/users.db" 2>/dev/null; }
lookup() { (cd $T && timeout 10 python3 lookup.py "$1" 2>&1); }
# marker: the method marker of hashdemo's hash, like $6$, in lower case.
marker() { getent shadow hashdemo | cut -d: -f2 | grep -o '^[$][^$]*[$]' | tr 'A-Z' 'a-z'; }
# run BIN ARG: what it prints, to stdout or stderr.
run() { (cd /tmp && LIBC_FATAL_STDERR_=1 timeout 5 "$T/$1" "$2" 2>&1); }
# probe TEXT: connect from the peer, check for a login prompt, send TEXT.
probe() {
	in_peer timeout 10 python3 -c '
import socket, sys, time
s = socket.create_connection(("10.99.0.1", 2323), 5)
s.settimeout(5)
b = b""
while b"login:" not in b:
    d = s.recv(200)
    if not d:
        break
    b += d
s.sendall(sys.argv[1].encode() + b"\r\n")
time.sleep(0.5)
sys.exit(0 if b"login:" in b else 1)
' "$1" 2>/dev/null
}
# logged TEXT: honeypot.log has a line from the peer with TEXT, within 5 seconds.
logged() { local i; for i in 1 2 3 4 5 6 7 8 9 10; do grep -q "10\.99\.0\.2.*$1" $T/honeypot.log 2>/dev/null && return 0; sleep 0.5; done; return 1; }

task 1 "greet and greet-fortify, and the ASLR setting"
need "a C compiler is installed" 'command -v gcc'
need "greet greets Alice" 'run greet Alice | grep -q "Hello, Alice"'
need "greet dies with stack smashing detected on 64 characters" 'run greet "$LONG" | grep -q "stack smashing detected"'
need "greet-fortify greets Alice" 'run greet-fortify Alice | grep -q "Hello, Alice"'
need "greet-fortify dies with buffer overflow detected on 64 characters" 'run greet-fortify "$LONG" | grep -q "buffer overflow detected"'
need "/root/lab-answers/1 has the ASLR setting" '[ "$(answer 1)" = "$(cat /proc/sys/kernel/randomize_va_space)" ]'

task 2 "users.db and lookup.py, string-built and parameterized"
need "users.db has a users table with alice and bob" '[ "$(names)" = "alice bob" ]'
need "lookup.py alice finds alice, and only alice, both ways" 'o=$(lookup alice); [ "$(echo "$o" | grep -E "^(string-built|parameterized):" | grep -c alice)" = 2 ] && ! echo "$o" | grep -q bob'
need "the injected name returns every row from the string-built query" 'lookup "$INJECT" | grep "^string-built:" | grep alice | grep -q bob'
need "and none from the parameterized one" 'lookup "$INJECT" | grep -Eq "^parameterized: *\[\]"'

task 3 "hashdemo's hash method"
need "/root/lab-answers/3 has the marker of hashdemo's hash" 'm=$(marker); [ -n "$m" ] && [ "$(answer 3)" = "$m" ]'

task 4 "A honeypot on 10.99.0.1:2323, logging to honeypot.log"
need "something listens on 10.99.0.1:2323" 'ss -ltnH "sport = :2323" | grep -Eq "10\.99\.0\.1:2323|0\.0\.0\.0:2323|\*:2323|\[::\]:2323"'
need "a client from the peer gets a login: prompt" 'probe "lab-check-probe"'
need "honeypot.log records the peer's address and what it sent" 'logged "lab-check-probe"'

task 5 "The peer's scan and logins, and the MAC that answers ARP"
need "/root/threats/scan.txt shows the nmap scan with 2323 open" 'grep -q "Nmap scan report for 10\.99\.0\.1" $T/scan.txt && grep -Eq "^2323/tcp +open" $T/scan.txt'
need "honeypot.log has a login attempt as root from the peer" 'grep -q "10\.99\.0\.2.*root" $T/honeypot.log'
need "honeypot.log has a login attempt as admin from the peer" 'grep -q "10\.99\.0\.2.*admin" $T/honeypot.log'
need "/root/lab-answers/5 has the MAC address that answers for 10.99.0.1" '[ "$(answer 5)" = "$(cat /sys/class/net/le-host/address)" ]'
