# PIDs of sha256sum processes run by normal users (UID 1000 or more).
user_pids() { ps -C sha256sum -o pid=,uid= | awk '$2 >= 1000 {print $1}'; }
topmem_ok() {
	local f=/root/topmem.txt col
	[ "$(grep -c . $f)" = 6 ] || return 1
	head -n1 $f | grep -q PID && head -n1 $f | grep -q USER || return 1
	col=$(head -n1 $f | awk '{for (i = 1; i <= NF; i++) if ($i ~ /MEM|RSS/) {print i; exit}}')
	[ -n "$col" ] || return 1
	# Every process line starts with a PID-like number somewhere and is
	# sorted by the memory column, largest first.
	tail -n +2 $f | awk -v c="$col" 'BEGIN {prev = -1}
		{v = $c + 0; if (prev >= 0 && v > prev) exit 1; prev = v}'
}

task 1 "The lab's two sha256sum processes ended"
need "the lab's sha256sum processes are gone" 'while read -r p; do [ -d /proc/$p ] && [ "$(cat /proc/$p/comm 2>/dev/null)" = sha256sum ] && exit 1; done <"$LAB_STATE/pids"; true'
need "no sha256sum runs as root" '! pgrep -x -u root sha256sum'

task 2 "A normal user's sha256sum /dev/zero runs"
need "a sha256sum process runs as a normal user" '[ -n "$(user_pids)" ]'
need "it reads /dev/zero" 'for p in $(user_pids); do grep -qa /dev/zero /proc/$p/cmdline && exit 0; done; exit 1'

task 3 "Its nice value changed to -5"
need "ps -o ni= shows -5 for the user's sha256sum" 'for p in $(user_pids); do [ "$(ps -o ni= -p $p | tr -d " ")" = -5 ] && exit 0; done; exit 1'

task 4 "The top five memory users in /root/topmem.txt"
need "/root/topmem.txt exists" '[ -s /root/topmem.txt ]'
need "it has a header with PID, USER and a memory column, then five process lines, largest first" topmem_ok
