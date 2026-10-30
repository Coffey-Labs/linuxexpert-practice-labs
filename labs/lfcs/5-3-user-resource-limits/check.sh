# A fresh login, as the guide tests it.
login_run() { sudo -niu "$1" bash -c "$2" </dev/null 2>/dev/null; }
uid=$(state_get alice-uid)
pid=$(systemctl show -p MainPID --value lab-worker 2>/dev/null)

# Task 3: two ssh logins as student2 that stay open, then a third.
two_in='' third_in=''
logins_try() {
	local d i n pids=()
	local ssh=(ssh -tt -i "$LAB_STATE/ssh-key" -o BatchMode=yes -o StrictHostKeyChecking=no
		-o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=10)
	d=$(mktemp -d)
	for i in 1 2; do
		"${ssh[@]}" student2@localhost 'echo le-lab-in; sleep 60' </dev/null >"$d/$i" 2>&1 &
		pids+=($!)
		# One at a time, so the second is counted with the first.
		for n in $(seq 40); do grep -q le-lab-in "$d/$i" && break; sleep 0.25; done
	done
	grep -q le-lab-in "$d/1" && grep -q le-lab-in "$d/2" && two_in=yes
	if [ -n "$two_in" ]; then
		timeout 20 "${ssh[@]}" student2@localhost 'echo le-lab-in' </dev/null >"$d/3" 2>&1
		grep -q le-lab-in "$d/3" && third_in=yes
	fi
	kill "${pids[@]}" 2>/dev/null
	wait "${pids[@]}" 2>/dev/null
	rm -rf "$d"
}
logins_try

task 1 "Each member of students limited to 50 processes"
need "student1's fresh login has ulimit -u 50 (soft and hard)" '[ "$(login_run student1 "ulimit -Su; ulimit -Hu" | paste -sd " ")" = "50 50" ]'
need "student2's fresh login has ulimit -u 50 (soft and hard)" '[ "$(login_run student2 "ulimit -Su; ulimit -Hu" | paste -sd " ")" = "50 50" ]'

task 2 "alice: open files 10000 soft, 20000 hard"
need "alice's fresh login has ulimit -Sn 10000 and -Hn 20000" '[ "$(login_run alice "ulimit -Sn; ulimit -Hn" | paste -sd " ")" = "10000 20000" ]'

task 3 "At most two simultaneous logins for students"
need "two ssh logins at once as student2 work (log out of student2's own sessions first)" '[ "$two_in" = yes ]'
need "a third ssh login as student2 is refused" '[ -z "$third_in" ]'

task 4 "lab-worker's open-file limits found, raised to 4096 while running"
need "/root/lab-answers/4 has the limits it started with, soft then hard" '[ "$(answer 4 | grep -o "[0-9]\+" | paste -sd " ")" = "512 1024" ]'
need "lab-worker is running" active lab-worker
need "lab-worker's process has open files 4096 soft and hard" '[ "$(awk "/^Max open files/ {print \$4, \$5}" /proc/$pid/limits)" = "4096 4096" ]'
need "it wasn't restarted with new limits: the unit still says 512:1024" '[ "$(systemctl show -p LimitNOFILESoft --value lab-worker):$(systemctl show -p LimitNOFILE --value lab-worker)" = 512:1024 ]'

task 5 "alice's processes capped together at 1 GiB of memory"
need "user-$uid.slice has MemoryMax=1073741824" '[ "$(systemctl show -p MemoryMax --value user-$uid.slice)" = 1073741824 ]'
need "other users aren't capped: student1's slice has no 1 GiB MemoryMax" '[ "$(systemctl show -p MemoryMax --value user-$(id -u student1).slice)" != 1073741824 ]'
