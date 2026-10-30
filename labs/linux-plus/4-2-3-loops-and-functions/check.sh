expected1() { awk -F: '$3 >= 1000 && $3 < 65534 {print $1 " -> " $7}' /etc/passwd; }
hosts_out() { (cd /tmp && timeout 20 bash /root/hosts.sh localhost 192.0.2.1 2>/dev/null); }

task 1 "Normal accounts and their shells"
need "/root/lab-answers/1 lists alice -> /bin/bash" 'grep -qx "alice -> /bin/bash" /root/lab-answers/1'
need "it lists every account with a UID from 1000 to 65533, and no others" 'diff <(expected1 | sort) <(grep . /root/lab-answers/1 | sort)'

task 2 "The pipe subshell trap"
need "/root/lab-answers/2 has pipe: 0" 'grep -qx "pipe: 0" /root/lab-answers/2'
need "it has process substitution: N with the number of entries in /etc" 'n=$(sed -n "s/^process substitution: //p" /root/lab-answers/2); [ -n "$n" ] && [ $((n - $(ls /etc | wc -l))) -le 3 ] && [ $(($(ls /etc | wc -l) - n)) -le 3 ]'

task 3 "~/hosts.sh with a function and a local variable"
need "~/hosts.sh exists" '[ -f /root/hosts.sh ]'
need "it defines a function with a local variable" 'grep -Eq "local +msg" /root/hosts.sh'
need "it prints checking localhost, then up" 'hosts_out | grep -A1 -x "checking localhost" | grep -qx "  up"'
need "it prints checking 192.0.2.1, then down" 'hosts_out | grep -A1 -x "checking 192.0.2.1" | grep -qx "  down"'
need "it ends with msg is still: global" '[ "$(hosts_out | tail -n1)" = "msg is still: global" ]'
