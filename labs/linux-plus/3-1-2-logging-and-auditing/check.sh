START=$(state_get start)
# events KEY: audit events with this key logged since the lab started.
events() {
	ausearch --input-logs -k "$1" --raw 2>/dev/null | grep '^type=SYSCALL' | grep -v 'comm="auditctl"' | grep -o 'msg=audit([0-9]*' |
		cut -d'(' -f2 | awk -v s="$START" '$1 > s {n++} END {exit !n}'
}

task 1 "The journal is persistent"
need "/var/log/journal exists" '[ -d /var/log/journal ]'
need "journald writes its system journal there" 'find /var/log/journal -name "system*.journal" | grep -q .'
need "journald isn't set to keep it in memory" '! grep -rhsEi "^[[:space:]]*Storage[[:space:]]*=[[:space:]]*(volatile|none)" /etc/systemd/journald.conf /etc/systemd/journald.conf.d'

task 2 "hello journal, tagged labtest, in the journal"
need "journalctl -t labtest shows hello journal" 'journalctl -q --no-pager -t labtest --since "@$START" | grep -q "hello journal"'

task 3 "logrotate rule for /var/log/labapp, tested and forced"
f=/etc/logrotate.d/labapp
need "$f exists for /var/log/labapp/*.log" 'grep -Eq "^[[:space:]]*/var/log/labapp/\*\.log" '$f
need "it rotates daily, keeps 3, compresses and has missingok" 'for w in "daily" "rotate[[:space:]]+3" "compress" "missingok"; do grep -Eq "^[[:space:]]*$w[[:space:]]*$" '$f' || exit 1; done'
need "logrotate -d accepts it" "logrotate -d $f"
need "a forced rotation left app.log.1.gz" '[ -f /var/log/labapp/app.log.1.gz ]'

task 4 "Audit watch on /etc/hosts tried, then removed"
need "ausearch -k hosts-change finds events since the lab started" 'events hosts-change'
need "the watch is removed again" '! auditctl -l 2>/dev/null | grep -q hosts-change'
need "the test line is out of /etc/hosts" '! grep -qx "# test" /etc/hosts'
