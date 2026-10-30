CONF="/etc/chrony.conf /etc/chrony.d /etc/chrony/chrony.conf /etc/chrony/conf.d /etc/chrony/sources.d"
# Every source line in chrony's configuration.
sources() { grep -rhsE '^[[:space:]]*(pool|server|peer)[[:space:]]' $CONF | awk '{print $1, $2}'; }
CLIENT=$(state_get client)

task 1 "The NTP client's service in /root/lab-answers/1"
need "the answer names the NTP client" 'answer 1 | grep -q "$CLIENT"'

task 2 "utc or local, for the hardware clock, in /root/lab-answers/2"
need "the answer is right" '[ "$(answer 2)" = "$(state_get rtc)" ]'

task 3 "chrony running with the single pool pool.ntp.org"
need "chrony is installed" 'pkg_installed chrony'
need "chrony is running" 'active "$(pick chronyd chrony)"'
need "chrony starts at boot" 'enabled "$(pick chronyd chrony)"'
need "chrony's configuration has pool pool.ntp.org" 'sources | grep -qx "pool pool.ntp.org"'
need "it has no other pool or server lines" '! sources | grep -vqx "pool pool.ntp.org"'
need "the running chronyd uses no other source names (restart it)" '! chronyc -n -N sources 2>/dev/null | awk "/^\^/ {print \$2}" | grep -v "pool\.ntp\.org" | grep -Evq "^[0-9.]+$|:"'
