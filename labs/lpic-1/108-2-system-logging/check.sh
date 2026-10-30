SINCE=$(state_get since)
storage=$(systemd-analyze cat-config systemd/journald.conf 2>/dev/null | sed -n 's/^[[:space:]]*Storage=//p' | tail -n1)
# wait_for FILE TEXT: up to 10 seconds for TEXT to show up in FILE.
wait_for() { local i; for i in $(seq 10); do grep -qsF "$2" "$1" && return 0; sleep 1; done; return 1; }

task 1 "A user.warning message tagged test in the journal"
need "journalctl -t test -p warning shows a message since the lab started" 'journalctl -q --no-pager --since "$SINCE" -t test -p warning..warning | grep -q .'

task 2 "rsyslog sends local3.* to /var/log/local3.log"
need "rsyslog is running" active rsyslog
need "a rule sends local3.* to /var/log/local3.log" 'grep -rhsEv "^[[:space:]]*#" /etc/rsyslog.conf /etc/rsyslog.d/*.conf | grep -E "local3\.(\*|info|debug)" | grep -q "/var/log/local3\.log"'
need "logger -p local3.info reaches /var/log/local3.log" 'm="le-lab check $$-$RANDOM"; logger -p local3.info "$m"; wait_for /var/log/local3.log "$m"'

task 3 "A persistent journal, with the previous boot readable"
need "/var/log/journal exists" '[ -d /var/log/journal ]'
need "journald isn't set to volatile or none" '[ "$storage" != volatile ] && [ "$storage" != none ]'
need "the journal is written to /var/log/journal" 'ls /var/log/journal/*/system*.journal'
need "journalctl -b -1 shows the previous boot" 'journalctl -q --no-pager -b -1 -n 1 | grep -q .'

task 4 "A logrotate rule for /var/log/lrtest/test.log, rotated"
need "/etc/logrotate.d/lrtest is a rule for /var/log/lrtest/test.log" 'grep -q "/var/log/lrtest/" /etc/logrotate.d/lrtest'
need "logrotate -d accepts the rule" 'logrotate -d /etc/logrotate.d/lrtest 2>&1 | grep -qi "error" && exit 1; logrotate -d /etc/logrotate.d/lrtest'
need "/var/log/lrtest has a rotated log" 'ls /var/log/lrtest/ | grep -Eq "^test\.log[.-][0-9]"'
