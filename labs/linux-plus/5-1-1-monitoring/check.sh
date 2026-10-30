START=$(state_get start)
UNIT=$(pick snmpd snmpd)
script() { ls /root/health.sh /home/*/health.sh 2>/dev/null | head -1; }
# run URL: run the student's script, with logger made harmless so the
# check doesn't log a critical message itself; print "EXIT OUTPUT".
run() {
	local d o rc; d=$(mktemp -d)
	printf '#!/bin/sh\nexit 0\n' >"$d/logger"; chmod 755 "$d/logger"
	o=$(PATH="$d:$PATH" timeout 30 bash "$(script)" "$1" 2>/dev/null); rc=$?
	rm -rf "$d"
	echo "$rc $o"
}
wait_snmp() { local i; for i in 1 2 3 4 5; do in_peer snmpget -v2c -c labro -t 2 -r 0 10.99.0.1 1.3.6.1.2.1.1.3.0 2>/dev/null | grep -qi timeticks && return 0; sleep 2; done; return 1; }

task 1 "SNMP agent answering the peer with community labro"
need "the SNMP client tools are installed (snmpget)" 'command -v snmpget'
need "snmpd is running and enabled" 'active snmpd && enabled snmpd'
need "snmpd.conf has a read-only community labro for 10.99.0.0/24" 'conf_has /etc/snmp/snmpd.conf "^[[:space:]]*rocommunity[[:space:]]+labro[[:space:]]+10\.99\.0\.0/24"'
need "snmpget from the peer returns the uptime" wait_snmp

task 2 "health.sh: OK, CRITICAL, and a critical log message"
need "health.sh is in your home directory" '[ -n "$(script)" ]'
need "the journal has its critical message for a failing URL" 'journalctl -q --no-pager -p crit --since "@$START" | grep -q "health: .* failing"'
need "it prints OK and exits 0 for http://127.0.0.1:8080/" '[ "$(run http://127.0.0.1:8080/)" = "0 OK" ]'
need "it prints CRITICAL and exits 2 for http://127.0.0.1:9/" '[ "$(run http://127.0.0.1:9/)" = "2 CRITICAL" ]'
