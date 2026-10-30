pkg_installed httpd && refuse "httpd is already installed; task 1 installs it. Remove it (dnf remove httpd) and start the lab again."
listening 80 tcp && refuse "something already listens on port 80; stop it and start the lab again."
listening 8080 tcp && refuse "something already listens on port 8080; stop it and start the lab again."
[ -d /etc/httpd ] && state_set had-etc-httpd 1
# A marker in /var/log/messages: tasks 2 and 4 look for messages after it.
token=le-lab-$(date +%s)-$RANDOM
state_set token "$token"
state_set since "$(date +%s)"
# Written straight into the file: through logger it can arrive late.
printf '%s %s le-lab: lab started %s\n' "$(date '+%b %e %T')" "$(hostname -s)" "$token" >>/var/log/messages
