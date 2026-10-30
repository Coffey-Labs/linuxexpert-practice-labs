page() { curl -s --max-time 5 -H "Host: $1" http://127.0.0.1/; }
new_test_mail() {
	local f
	for f in /var/mail/* /var/spool/mail/* /root/mbox /home/*/mbox; do
		[ -f "$f" ] && [ "$f" -nt "$LAB_STATE/started" ] && grep -q '^Subject: test' "$f" && return 0
	done
	return 1
}

task 1 "Nginx serves lab.test from /srv/www/lab" debian
need "nginx is running" active nginx
need "/srv/www/lab/index.html exists" '[ -s /srv/www/lab/index.html ]'
need "a file in /etc/nginx/conf.d/ sets up lab.test" 'grep -qs "server_name.*lab\.test" /etc/nginx/conf.d/*.conf'
need "nginx -t passes" 'nginx -t'
need "http://127.0.0.1/ with Host lab.test returns /srv/www/lab/index.html" 'page lab.test | cmp -s - /srv/www/lab/index.html'

task 2 "Apache serves shop.test from /srv/www/shop" rhel
need "httpd is running" active httpd
need "httpd starts at boot" enabled httpd
need "/srv/www/shop/index.html exists" '[ -s /srv/www/shop/index.html ]'
need "SELinux is enforcing" '[ "$(getenforce)" = Enforcing ]'
need "the SELinux rules give /srv/www/shop httpd_sys_content_t" 'matchpathcon /srv/www/shop/index.html | grep -q httpd_sys_content_t'
need "index.html has that label now" 'ls -Z /srv/www/shop/index.html | grep -q httpd_sys_content_t'
need "http://127.0.0.1/ with Host shop.test returns /srv/www/shop/index.html" 'page shop.test | cmp -s - /srv/www/shop/index.html'

task 3 "Local mail with the subject test delivered"
need "postfix is running" active postfix
need "a mailbox has a new message with the subject test" new_test_mail
