D=/root/diskcheck.sh
used=$(df --output=pcent / | tail -1 | tr -dc '0-9')
# run LIMIT: "exit-code first-word"
run() { local out rc; out=$("$D" "$@" 2>/dev/null); rc=$?; echo "$rc ${out%%:*}"; }
has() { grep -qxF -- "$2" "/root/lab-answers/$1"; }

task 1 "~/diskcheck.sh with limits and exit codes"
need "~/diskcheck.sh is executable" '[ -x "$D" ]'
need "below the limit minus 10 it prints ok and exits 0" '[ "$(run $((used + 11)))" = "0 ok" ]'
need "within 10 of the limit it prints warn and exits 1" '[ "$(run $((used + 5)))" = "1 warn" ]'
need "at the limit it prints ALERT and exits 2" '[ "$(run "$used")" = "2 ALERT" ]'
need "the message names / and the percentage" '"$D" "$used" | grep -qx "ALERT: / is ${used}%"'
need "without an argument the limit is 80" '[ "$(run)" = "$(run 80)" ]'

task 2 "File and string tests saved"
need "/etc/passwd: file" 'has 2 "/etc/passwd: file"'
need "/etc: dir" 'has 2 "/etc: dir"'
need "/nope: missing" 'has 2 "/nope: missing"'
need "/bin: link" 'has 2 "/bin: link"'
need "empty" 'has 2 empty'
need "string compare says 10 < 9" 'has 2 "string compare says 10 < 9"'

task 3 "Regex and case output saved"
need "10.0.5.21: ipv4" 'has 3 "10.0.5.21: ipv4"'
need "10.0.5: not ipv4 and web01: not ipv4" 'has 3 "10.0.5: not ipv4" && has 3 "web01: not ipv4"'
need "start ok and stop ok" 'has 3 "start ok" && has 3 "stop ok"'
need "bogus unknown" 'has 3 "bogus unknown"'
