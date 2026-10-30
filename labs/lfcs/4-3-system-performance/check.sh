# Every process of index-builder.service runs at nice 15.
all_nice15() {
	local cg p n=0
	cg=$(systemctl show -p ControlGroup --value index-builder)
	[ -n "$cg" ] || return 1
	for p in $(cat "/sys/fs/cgroup$cg/cgroup.procs"); do
		[ "$(ps -o ni= -p "$p" | tr -d ' ')" = 15 ] || return 1
		n=$((n + 1))
	done
	[ "$n" -gt 0 ]
}

# Line N of answer 3 names the planted unit or what this boot shows.
names_unit() { # LINE PLANTED ACTUAL
	local a
	a=$(sed -n "$1p" /root/lab-answers/3 2>/dev/null | tr 'A-Z' 'a-z')
	[ -n "$a" ] || return 1
	case $a in *"$2"*) return 0 ;; esac
	[ -n "$3" ] && case $a in *"${3%.service}"*) return 0 ;; esac
	return 1
}
slowest() { systemd-analyze blame --no-pager 2>/dev/null | awk 'NR == 1 {print $2}'; }
critical() { systemd-analyze critical-chain --no-pager 2>/dev/null | grep -m1 ' +[0-9]' | sed 's/^[^a-zA-Z0-9]*//; s/ .*//'; }

sysstat_on() {
	enabled sysstat-collect.timer && active sysstat-collect.timer || return 1
	is_rhel || grep -Eq '^ENABLED="?true' /etc/default/sysstat
}

# The time in answer 4 is the end or start of a sar -u row with the lowest
# %idle (within 3 points).
busiest_ok() {
	local a
	a=$(head -n1 /root/lab-answers/4 2>/dev/null | grep -oE '[0-9]{1,2}:[0-9]{2}(:[0-9]{2})?( ?[AaPp][Mm])?' | head -n1)
	[ -n "$a" ] && a=$(date -d "$a" +%H:%M 2>/dev/null) || return 1
	LC_ALL=C S_TIME_FORMAT=ISO sar -u 2>/dev/null | awk -v a="$a" '
		$1 ~ /^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]$/ {
			if ($2 == "all" && $NF ~ /^[0-9.]+$/) {
				n++; end[n] = substr($1, 1, 5); start[n] = prev; idle[n] = $NF + 0
				if (n == 1 || idle[n] < min) min = idle[n]
			}
			prev = substr($1, 1, 5)
		}
		END {
			for (i = 1; i <= n; i++) if (idle[i] <= min + 3 && (end[i] == a || start[i] == a)) exit 0
			exit 1
		}'
}

# Answer 5 has a PID the kernel logged as killed, in any boot.
oom_ok() {
	local pid
	pid=$(grep -oE 'Killed process [0-9]+' /root/lab-answers/5 2>/dev/null | head -n1 | awk '{print $3}')
	[ -n "$pid" ] || pid=$(grep -oE '[0-9]+' /root/lab-answers/5 2>/dev/null | head -n1)
	[ -n "$pid" ] && journalctl -q --no-pager _TRANSPORT=kernel | grep -q "Killed process $pid "
}

task 1 "The service causing the load named"
need "/root/lab-answers/1 names the service" 'answer 1 | grep -q index-builder'

task 2 "index-builder runs at nice 15"
need "index-builder.service is running" active index-builder.service
need "its unit sets nice 15, so it holds after a restart" '[ "$(systemctl show -p Nice --value index-builder)" = 15 ]'
need "every process of the service runs at nice 15" all_nice15

task 3 "Slowest unit and critical-path unit of the last boot"
need "line 1 of /root/lab-answers/3 names the slowest unit" 'names_unit 1 cache-warmup "$(slowest)"'
need "line 2 names the unit on the critical path" 'names_unit 2 inventory-sync "$(critical)"'

task 4 "sysstat collecting; busiest interval found"
need "sysstat collection is on and starts at boot" sysstat_on
need "/root/lab-answers/4 has the time of the sar -u row with the lowest %idle" busiest_ok

task 5 "Evidence of an out-of-memory kill"
need "/root/lab-answers/5 has a PID the kernel log shows as killed" oom_ok
