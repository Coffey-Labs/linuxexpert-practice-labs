sysstat_on() {
	enabled sysstat-collect.timer && active sysstat-collect.timer || return 1
	is_rhel || grep -Eq '^ENABLED="?true' /etc/default/sysstat
}
slowest() { systemd-analyze blame --no-pager 2>/dev/null | awk 'NR == 1 {print $2}'; }

task 1 "sysstat collection on, now and at boot"
need "sysstat-collect.timer is enabled and running (and ENABLED=true on Ubuntu)" sysstat_on

task 2 "The CPU hog's service named and stopped"
need "/root/lab-answers/2 names the service" 'answer 2 | grep -q report-builder'
need "report-builder is stopped and disabled" '! active report-builder && ! enabled report-builder'

task 3 "The process that switches context most"
need "/root/lab-answers/3 names it" 'answer 3 | grep -q msgbroker'

task 4 "The unit that slowed the last boot most"
need "/root/lab-answers/4 names it" 'a=$(answer 4); s=$(slowest); [ -n "$a" ] && { [[ $a == *cache-prime* ]] || { [ -n "$s" ] && [[ $a == *${s%.service}* ]]; }; }'
