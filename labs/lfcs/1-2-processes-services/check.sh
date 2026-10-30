# The web server: the one running, else the first one installed.
web=''
for s in nginx httpd apache2; do active "$s" && { web=$s; break; }; done
if [ -z "$web" ]; then
	for s in nginx httpd apache2; do systemctl cat "$s.service" >/dev/null 2>&1 && { web=$s; break; }; done
fi

task 1 "Start, find, renice and stop sleep 3000 as alice" self

task 2 "nginx or httpd runs now and at every boot"
need "nginx or httpd is installed" '[ -n "$web" ]'
need "the web server is running" active "$web"
need "the web server starts at boot" enabled "$web"

task 3 "Web server config error found in the logs, fixed"
need "/root/lab-answers/3 holds the error line, naming the file and line" 'grep -Eq "/etc/(nginx|httpd|apache2)/[^ ]*:[0-9]+|line [0-9]+ of /etc/(httpd|apache2)/" /root/lab-answers/3'
need "the web server's configuration test passes" 'case $web in nginx) nginx -t ;; httpd) httpd -t ;; apache2) apache2ctl -t ;; *) false ;; esac'
need "the web server is running" active "$web"
need "curl -sI localhost returns a status line" 'curl -sI --max-time 5 http://localhost/ | head -n1 | grep -q "^HTTP/"'

task 4 "The cups service can't be started"
need "cups.service is masked" '[ "$(systemctl is-enabled cups.service 2>/dev/null)" = masked ]'
need "cups isn't running" '! systemctl is-active --quiet cups.service'

task 5 "Boot to a text login by default"
need "the default target is multi-user.target" '[ "$(systemctl get-default)" = multi-user.target ]'
