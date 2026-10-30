line() { sed -n "${2}p" "/root/lab-answers/$1" 2>/dev/null | tr -d '[:space:]'; }
# Today's sar -d rows with figures in them.
sar_rows() {
	S_TIME_FORMAT=ISO LC_ALL=C sar -d -p 2>/dev/null |
		awk '$1 ~ /^[0-9]+:[0-9]+:[0-9]+$/ && !/DEV|RESTART/ && NF >= 8' | wc -l
}

task 1 "Busiest device and process in /root/lab-answers/1"
need "line 1 names the busiest device" '[ "$(line 1 1 | sed "s#^/dev/##")" = loop42 ]'
need "line 2 names the process" '[ "$(sed -n 2p /root/lab-answers/1 | awk "{print \$1}" | sed "s#.*/##")" = reindexd ]'

task 2 "fio figures in /root/lab-answers/2, test file removed"
need "fio is installed" 'command -v fio'
need "line 1 is a throughput such as 188MiB/s" 'line 2 1 | sed "s/^BW=//" | grep -Eq "^[0-9.]+[kKMG]i?B/s$"'
need "line 2 is an IOPS figure such as 48.2k" 'line 2 2 | sed "s/^IOPS=//" | grep -Eq "^[0-9.]+[kKM]?$"'
need "no test file is left in /data" '[ -z "$(find /data -xdev -type f -size +1M)" ]'

task 3 "loop41's scheduler found, then set to mq-deadline"
need "/root/lab-answers/3 names loop41's original scheduler" '[ "$(answer 3 | tr -d "[]")" = "$(state_get scheduler)" ]'
need "loop41 uses mq-deadline now" 'grep -q "\[mq-deadline\]" /sys/block/loop41/queue/scheduler'

task 4 "loop41 keeps mq-deadline after a reboot"
need "a udev rule (or tuned profile) sets the scheduler" '[ -n "$(grep -rlsE "queue/scheduler|elevator" /etc/udev/rules.d /etc/tuned)" ]'
need "loop41 uses mq-deadline" 'grep -q "\[mq-deadline\]" /sys/block/loop41/queue/scheduler'

task 5 "sysstat collecting; sar -d shows today's disk activity"
need "sysstat collection is on (sysstat-collect.timer active)" active sysstat-collect.timer
need "it starts at boot" 'enabled sysstat || enabled sysstat-collect.timer'
need "sar -d -p shows rows for today" '[ "$(sar_rows)" -gt 0 ]'
