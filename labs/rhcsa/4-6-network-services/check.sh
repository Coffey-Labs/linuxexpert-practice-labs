since_start() {
	local t; t=$(state_get token)
	if grep -q "$t" /var/log/messages; then
		sed -n "/$t/,\$p" /var/log/messages
	elif [ "$(stat -c %W /var/log/messages)" -gt "$(state_get since)" ]; then
		cat /var/log/messages    # rotated since the lab started
	fi
}
# listening_soon PORT: something listens on PORT within 15 seconds.
listening_soon() { local i; for i in $(seq 15); do listening "$1" tcp && return 0; sleep 1; done; return 1; }
# A stop of httpd on its own: "Stopped httpd" not followed within a second
# by a start (a restart) and not part of a shutdown (a boot comes before
# the next start).
stopped_alone() {
	since_start | awk '
		function t(  s) { s = $3; split(s, a, ":"); return a[1] * 3600 + a[2] * 60 + a[3] }
		/systemd\[1\]: Stopped httpd\.service/ { stop = t(); seen = 1; next }
		/kernel: Linux version|kernel: Command line:/ { seen = 0; next }
		/systemd\[1\]: Start(ing|ed) httpd\.service/ && seen { d = t() - stop; if (d < 0) d += 86400; if (d >= 2) ok = 1; seen = 0 }
		END { exit !ok }'
}

task 1 "httpd installed, running, enabled, on port 80"
need "httpd is installed" 'rpm -q httpd'
need "httpd is active" active httpd
need "httpd starts at boot" enabled httpd
need "httpd listens on port 80" 'listening_soon 80 && ss -Htlnp "sport = :80" | grep -q httpd'

task 2 "httpd stopped (and started again)"
need "httpd is installed" 'rpm -q httpd'
need "the log shows httpd was stopped (not just restarted) since the lab started" stopped_alone

task 3 "Listen 8080 in conf.d; httpd on 80 and 8080"
need "a file in /etc/httpd/conf.d/ has Listen 8080" 'conf_has /etc/httpd/conf.d "^[[:space:]]*Listen[[:space:]]+([0-9.]+:|\[[0-9a-f:]+\]:)?8080([[:space:]]|$)"'
need "httpd listens on port 8080" 'listening_soon 8080 && ss -Htlnp "sport = :8080" | grep -q httpd'
need "httpd still listens on port 80" 'listening 80 tcp'

task 4 "httpd failed on a broken configuration, then fixed"
need "the log shows httpd failed to start since the lab started" 'since_start | grep -Eq "httpd\.service: (Failed with result|Main process exited, code=exited, status=1)"'
need "httpd -t finds no errors" 'httpd -t'
need "httpd is active again" active httpd
