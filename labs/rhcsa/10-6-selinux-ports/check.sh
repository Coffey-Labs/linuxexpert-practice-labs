peer_curl() {
	local i
	for i in 1 2 3 4 5; do
		in_peer curl -s --max-time 3 http://10.99.0.1:8888/ | grep -q "Lab httpd" && return 0
		sleep 2
	done
	return 1
}
banner() { timeout 5 bash -c "exec 3<>/dev/tcp/127.0.0.1/$1; head -c 7 <&3" 2>/dev/null | grep -q "^SSH-"; }

task 1 "httpd on 8888 as well as 80, reachable from the peer"
need "SELinux is enforcing" '[ "$(getenforce)" = Enforcing ]'
need "httpd is running" active httpd
need "port 8888 is labeled http_port_t (semanage port -l -C)" 'semanage port -l -C | grep -Eq "^http_port_t[[:space:]]+tcp[[:space:]].*\b8888\b"'
need "httpd listens on 8888 and 80" 'listening 8888 tcp && listening 80 tcp'
if systemctl is-active --quiet firewalld; then
	need "the firewall allows 8888/tcp, now and permanently" 'firewall-cmd --query-port=8888/tcp && firewall-cmd --permanent --query-port=8888/tcp'
fi
need "curl http://10.99.0.1:8888/ from the peer gets an answer" peer_curl

task 2 "sshd on 2222 as well as 22"
need "port 2222 is labeled ssh_port_t" 'semanage port -l | grep -Eq "^ssh_port_t[[:space:]]+tcp[[:space:]].*\b2222\b"'
need "a file in /etc/ssh/sshd_config.d/ has Port 2222" 'grep -Eqs "^[[:space:]]*Port[[:space:]]+2222[[:space:]]*$" /etc/ssh/sshd_config.d/*.conf'
need "sshd's configuration has ports 22 and 2222" 'sshd -T 2>/dev/null | grep -qx "port 22" && sshd -T 2>/dev/null | grep -qx "port 2222"'
need "sshd answers on port 2222" 'banner 2222'
need "sshd still answers on port 22" 'banner 22'
