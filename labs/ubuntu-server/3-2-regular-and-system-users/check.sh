# names FILE: the account names in FILE, sorted, one per line.
names() { tr -s ' ,\t' '\n' <"$1" 2>/dev/null | sed 's/:.*//' | grep -v '^$' | sort -u; }
shells() { grep -v -E 'nologin|false|sync$' /etc/passwd | cut -d: -f1 | sort -u; }
uids() { awk -F: '$3 >= 1000 { print $1 }' /etc/passwd | sort -u; }
# same_set FILE CMD: FILE names the same accounts as CMD prints (sync is
# optional, since its shell is /bin/sync).
same_set() { [ -s "$1" ] && [ "$(names "$1" | grep -vx sync)" = "$($2 | grep -vx sync)" ]; }
# The service: the process listening on 8080.
port_pid() { ss -Hltnp 'sport = :8080' | grep -o 'pid=[0-9]*' | head -n1 | cut -d= -f2; }
web_up() {
	local i
	for i in $(seq 20); do
		curl -s --max-time 2 http://localhost:8080/ | grep -qi '<html\|<!DOCTYPE' && return 0
		sleep 1
	done
	return 1
}
unit_of() { ps -o unit= -p "$1" | tr -d ' '; }

task 1 "Accounts with a shell, and accounts with UID 1000 or more"
need "/root/lab-answers/1-shells lists exactly the accounts with a login shell" 'same_set /root/lab-answers/1-shells shells'
need "/root/lab-answers/1-uids lists exactly the accounts with UID 1000 or more" 'same_set /root/lab-answers/1-uids uids'

task 2 "System user reportsvc with its own group and data directory"
need "user reportsvc exists" 'id reportsvc'
need "its UID is below 1000" '[ "$(id -u reportsvc)" -lt 1000 ]'
need "its primary group is reportsvc" '[ "$(id -gn reportsvc)" = reportsvc ]'
need "it has no login shell" 'getent passwd reportsvc | grep -Eq ":(/usr/sbin/nologin|/sbin/nologin|/usr/bin/false|/bin/false)$"'
need "/var/lib/reportsvc is owned by reportsvc" '[ "$(stat -c %U /var/lib/reportsvc)" = reportsvc ]'
need "only reportsvc can write to /var/lib/reportsvc" '[ $(( 0$(stat -c %a /var/lib/reportsvc) & 022 )) -eq 0 ]'
need "reportsvc can create files in /var/lib/reportsvc" 'f=/var/lib/reportsvc/.le-check-$$; runuser -u reportsvc -- touch $f && rm -f $f'
need "reportsvc can't create files in /etc" 'f=/etc/.le-check-$$; ! runuser -u reportsvc -- touch $f; r=$?; rm -f $f; exit $r'

task 3 "An http.server on 8080 runs as reportsvc from a unit at boot"
need "curl -s localhost:8080 prints HTML" web_up
need "the server on 8080 runs as reportsvc" '[ "$(ps -o user= -p "$(port_pid)" | tr -d " ")" = reportsvc ]'
need "it's a systemd service" 'unit_of "$(port_pid)" | grep -q "\.service$"'
need "the service is enabled at boot" 'enabled "$(unit_of "$(port_pid)")"'
