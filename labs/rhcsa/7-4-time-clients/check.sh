# The sources chronyd uses now, one address per line.
sources() { chronyc -n -c sources 2>/dev/null | cut -d, -f3; }
synced() {
	local i
	for i in $(seq 15); do
		chronyc -n sources 2>/dev/null | grep -Eq '^\^\*[[:space:]]+10\.99\.0\.2[[:space:]]' && return 0
		sleep 2
	done
	return 1
}
# server, pool and peer lines in chrony's configuration.
conf_sources() {
	{ cat /etc/chrony.conf; ls /etc/chrony.d/*.conf 2>/dev/null | xargs -r cat; } |
		grep -E '^[[:space:]]*(server|pool|peer)[[:space:]]' | awk '{print $2}'
}

task 1 "chronyd uses only ntp1 (10.99.0.2), synchronized"
need "chronyd is running" active chronyd
need "chronyd starts at boot" enabled chronyd
need "chrony's configuration names ntp1 (10.99.0.2)" 'conf_sources | grep -Eqx "10\.99\.0\.2|ntp1(\.lab\.example)?"'
need "chrony's configuration names no other server or pool" '! conf_sources | grep -Evqx "10\.99\.0\.2|ntp1(\.lab\.example)?"'
need "chronyc sources lists only 10.99.0.2" '[ "$(sources | sort -u)" = 10.99.0.2 ]'
need "10.99.0.2 is marked ^* (synchronized)" synced

task 2 "Time zone America/Phoenix"
need "timedatectl shows America/Phoenix" '[ "$(timedatectl show -p Timezone --value)" = America/Phoenix ]'
need "/etc/localtime points at America/Phoenix" 'readlink /etc/localtime | grep -q "America/Phoenix$"'
