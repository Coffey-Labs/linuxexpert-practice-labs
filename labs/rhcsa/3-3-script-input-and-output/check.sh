run() { timeout 30 "$@"; }
CF=/usr/local/bin/count-files
usage_ok() {
	local err rc
	err=$(run "$@" 2>&1 >/dev/null); rc=$?
	[ "$rc" = 1 ] && [ "$err" = "usage: count-files DIRECTORY" ] && [ -z "$(run "$@" 2>/dev/null)" ]
}
TODAY=/root/df-$(date +%F).txt

task 1 "count-files counts entries; usage message and exit 1"
need "$CF exists and is executable" '[ -x $CF ]'
need "count-files /etc/skel prints the same number as ls -A /etc/skel | wc -l" '[ "$(run $CF /etc/skel 2>/dev/null)" = "$(ls -A /etc/skel | wc -l)" ]'
need "it counts hidden entries too (6 in a test directory)" '[ "$(run $CF "$LAB_STATE/count" 2>/dev/null)" = 6 ]'
need "with no argument it prints the usage to standard error and exits 1" 'usage_ok $CF'
need "with a file instead of a directory, the same" 'usage_ok $CF /etc/hosts'

task 2 "homes.sh prints home directories or NAME: no such user"
need "/root/homes.sh exists and is executable" '[ -x /root/homes.sh ]'
need "homes.sh root nosuchuser student prints /root, the error line and /home/student" '[ "$(run /root/homes.sh root nosuchuser student 2>&1)" = "$(printf "/root\nnosuchuser: no such user\n/home/student")" ]'

task 3 "df-today.sh saves df -h / to a file named after today's date"
need "/root/df-today.sh exists and is executable" '[ -x /root/df-today.sh ]'
need "$TODAY exists (run the script)" 'run /root/df-today.sh >/dev/null 2>&1; [ -f $TODAY ]'
need "it holds the output of df -h /" '[ "$(head -n1 $TODAY | awk "{print \$1}")" = Filesystem ] && [ "$(tail -n1 $TODAY | awk "{print \$NF}")" = / ]'

task 4 "sumlines.sh adds up the line counts of its arguments"
need "/root/sumlines.sh exists and is executable" '[ -x /root/sumlines.sh ]'
need "its number matches cat FILES | wc -l" '[ "$(run /root/sumlines.sh /etc/passwd /etc/group /etc/hosts 2>/dev/null | tr -d " \t")" = "$(cat /etc/passwd /etc/group /etc/hosts | wc -l)" ]'
need "it works for one file too" '[ "$(run /root/sumlines.sh /etc/services 2>/dev/null | tr -d " \t")" = "$(wc -l </etc/services)" ]'
