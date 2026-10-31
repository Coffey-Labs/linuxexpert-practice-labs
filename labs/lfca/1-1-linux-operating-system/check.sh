. /etc/os-release
A=/root/lab-answers
PID=$(state_get sleep-pid)
cpus() { lscpu | awk -F: '/^CPU\(s\):/ {gsub(/ /, "", $2); print $2}'; }
# has FILE VALUE: a line of FILE is VALUE (case and spaces ignored).
has() { sed 's/^[[:space:]]*//; s/[[:space:]]*$//' "$1" 2>/dev/null | grep -qixF -- "$2"; }

task 1 "Distribution, version and kernel in /root/lab-answers/1"
need "the answer has the ID, $ID" 'has $A/1 "$ID"'
need "the answer has the VERSION_ID, $VERSION_ID" 'has $A/1 "$VERSION_ID"'
need "the answer has the kernel version from uname -r" 'has $A/1 "$(uname -r)"'

task 2 "PID 1's program in /root/lab-answers/2"
need "the answer names systemd (or init, its other name)" '[[ "$(answer 2)" =~ (systemd|init) ]]'

task 3 "The sleep process's PID found and the process ended"
need "/root/lab-answers/3 has the sleep process's PID" '[ "$(answer 3)" = "$PID" ]'
need "the process has ended" '! ps -o args= -p "$PID" | grep -q "sleep 6000"'

task 4 "tree installed, its files listed, and removed again"
need "/root/lab-answers/4 has the path of the tree program" '[ "$(answer 4)" = /usr/bin/tree ]'
need "the tree package is removed" '! pkg_installed tree'

task 5 "The number of CPUs in /root/lab-answers/5"
need "the answer is the CPU count lscpu shows" '[ "$(answer 5)" = "$(cpus)" ]'
