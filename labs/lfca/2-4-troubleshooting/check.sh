page() {
	local i
	for i in 1 2 3 4 5; do
		[ "$(curl -s -o /dev/null -w '%{http_code}' --max-time 3 http://localhost/)" = 200 ] && return 0
		sleep 2
	done
	return 1
}

task 1 "The large file in /data found"
need "/root/lab-answers/1 has the large file's full path" '[ "$(head -n1 /root/lab-answers/1 | sed "s/^[[:space:]]*//; s/[[:space:]]*$//")" = "$(state_get big)" ]'

task 2 "nginx's configuration fixed; nginx running"
need "nginx -t finds no errors" 'nginx -t'
need "nginx starts at boot" enabled nginx
need "nginx is running" active nginx
need "curl localhost gets a page" page

task 3 "A wrong DNS server diagnosed and put back" self
task 4 "Load watched in top" self
task 5 "Recovered from emergency mode" self
