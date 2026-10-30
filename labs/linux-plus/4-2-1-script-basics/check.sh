I=/root/info.sh

task 1 "~/info.sh with arguments and exit codes"
need "~/info.sh is executable" '[ -x "$I" ]'
need "it starts with a bash shebang" 'head -n1 "$I" | grep -Eq "^#!(/usr)?/bin/(env )?bash"'
need "it uses set -u" 'grep -Eq "^[[:space:]]*set -[a-z]*u" "$I"'
need "info.sh localhost prints Checking localhost and up, and exits 0" 'out=$("$I" localhost) && grep -q "Checking localhost (1 args" <<<"$out" && grep -qx up <<<"$out"'
need "info.sh 192.0.2.1 prints down and exits 1" 'out=$("$I" 192.0.2.1); [ $? = 1 ] && grep -qx down <<<"$out"'
need "with no argument it checks this machine's hostname" '"$I" | grep -q "Checking $(hostname) (0 args"'

task 2 "Parameter expansion of the nginx log path"
need "/root/lab-answers/2 has the expanded line" '[ "$(answer 2)" = "access.log /var/log/nginx /var/log/nginx/access.old 25 /var/log/nginx/access.log" ]'
need "the last field is in capitals" 'grep -q " /VAR/LOG/NGINX/ACCESS.LOG$" /root/lab-answers/2'
