# PIDs of "sleep 1000" processes that aren't root's, with niceness 12.
sleep12() { ps -eo pid=,ni=,user=,args= | awk '$2 == 12 && $3 != "root" && $4 == "sleep" && $5 == "1000" && NF == 5 { print $1 }'; }

task 1 "nginx's master, workers and unit found"
need "nginx is installed" pkg_installed nginx
need "/root/lab-answers/1-master names the master's user, root" '[ "$(answer 1-master)" = root ]'
need "/root/lab-answers/1-workers names the workers' user, www-data" '[ "$(answer 1-workers)" = www-data ]'
need "/root/lab-answers/1-unit names the unit, nginx.service" 'case $(answer 1-unit) in nginx|nginx.service) true ;; *) false ;; esac'

task 2 "sleep 1000 of yours, at niceness 12"
need "a sleep 1000 runs as a user other than root" 'ps -eo user=,args= | awk "\$1 != \"root\" && \$2 == \"sleep\" && \$3 == \"1000\"" | grep -q .'
need "its niceness is 12" '[ -n "$(sleep12)" ]'

task 3 "nginx reloaded by a signal, then stopped"
need "nginx is installed" pkg_installed nginx
need "nginx is stopped (systemctl is-active says inactive)" '[ "$(systemctl is-active nginx)" = inactive ]'
need "no nginx processes are left" '! pgrep -x nginx'
