# page URL: what URL serves is /srv/www/index.html, polling for a few
# seconds.
page() {
	local i
	[ -s /srv/www/index.html ] || return 1
	for i in 1 2 3 4 5; do
		[ "$(curl -s -m 3 "$1")" = "$(cat /srv/www/index.html)" ] && return 0
		sleep 2
	done
	return 1
}
# fw ARG: firewalld, if it's running, allows ARG (--query-service=http)
# now and permanently.
fw() { ! active firewalld || { firewall-cmd -q "$1" && firewall-cmd -q --permanent "$1"; }; }

task 1 "Apache serves /srv/www, labeled httpd_sys_content_t by a file context rule"
need "SELinux is enforcing" '[ "$(getenforce)" = Enforcing ]'
need "/srv/www/index.html exists" '[ -s /srv/www/index.html ]'
need "a file context rule labels /srv/www httpd_sys_content_t (semanage fcontext -l -C)" 'semanage fcontext -l -C | grep -E "^/srv/www" | grep -q httpd_sys_content_t'
need "/srv/www/index.html has the type httpd_sys_content_t" '[ "$(stat -c %C /srv/www/index.html | cut -d: -f3)" = httpd_sys_content_t ]'
need "restorecon wouldn't change anything in /srv/www" '[ -z "$(restorecon -Rnv /srv/www)" ]'
need "httpd is running and enabled" 'active httpd && enabled httpd'
need "curl http://localhost/ gets /srv/www/index.html" 'page http://localhost/'
need "the firewall allows http, now and permanently, if it's running" 'fw --query-service=http'

task 2 "httpd_can_network_connect on, persistently"
need "getsebool httpd_can_network_connect shows on" 'getsebool httpd_can_network_connect | grep -q "> on$"'
need "it stays on at boot (semanage boolean -l -C)" 'semanage boolean -l -C | grep -Eq "^httpd_can_network_connect +\(on +, +on\)"'

task 3 "Port 8888/tcp labeled http_port_t, and Apache listening on it"
need "SELinux is enforcing" '[ "$(getenforce)" = Enforcing ]'
need "8888/tcp is labeled http_port_t (semanage port -l -C)" 'semanage port -l -C | grep -E "^http_port_t +tcp" | grep -Eq "\b8888\b"'
need "httpd listens on port 8888" 'ss -Hltnp "sport = :8888" | grep -q httpd'
need "curl http://localhost:8888/ gets /srv/www/index.html" 'page http://localhost:8888/'
need "the firewall allows 8888/tcp, now and permanently, if it's running" 'fw --query-port=8888/tcp'
