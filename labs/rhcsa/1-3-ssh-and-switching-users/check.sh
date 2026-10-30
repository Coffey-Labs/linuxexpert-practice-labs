# The part of /var/log/secure written since the lab started.
since_start() {
	local t; t=$(state_get token)
	if grep -q "$t" /var/log/secure; then
		sed -n "/$t/,\$p" /var/log/secure
	elif [ "$(stat -c %W /var/log/secure)" -gt "$(state_get since)" ]; then
		cat /var/log/secure    # rotated since the lab started
	fi
}

task 1 "hostname run on the peer over SSH, its output in /root/lab-answers/1"
need "tester logged in to the peer over SSH (from 10.99.0.1)" 'since_start | grep -Eq "Accepted [a-z-]+ for tester from 10\.99\.0\.1 "'
need "/root/lab-answers/1 holds the name hostname printed there" '[ "$(answer 1)" = "$(hostname | tr A-Z a-z)" ]'

task 2 "User alice with a password, switched to with su -"
need "user alice exists" id alice
need "alice's home is /home/alice" '[ "$(getent passwd alice | cut -d: -f6)" = /home/alice ] && [ -d /home/alice ]'
need "alice has a password" '[ -n "$(getent shadow alice | cut -d: -f2 | tr -d "!*")" ]'
need "someone switched to alice with a login shell (su - alice)" 'since_start | grep -q "su-l:session): session opened for user alice"'

task 3 "id run as alice, its output in /root/lab-answers/3"
need "/root/lab-answers/3 starts with alice's UID and name" 'id alice >/dev/null && head -n1 /root/lab-answers/3 | grep -q "^uid=$(id -u alice)(alice) "'

task 4 "alice logged in on tty2"
need "who lists alice on tty2" 'who | grep -Eq "^alice[[:space:]]+tty2[[:space:]]"'
