nodes_wait 60 || true
# fw NODE WHAT ITEM: ITEM is in NODE's firewall-cmd --list-WHAT (runtime) and
# --permanent --list-WHAT.
fw() {
	in_node "$1" firewall-cmd --list-"$2" | tr ' ' '\n' | grep -qx "$3" &&
		in_node "$1" firewall-cmd --permanent --list-"$2" | tr ' ' '\n' | grep -qx "$3"
}
# web: the page on node1 answers from here, polling for a few seconds.
web() {
	local i
	for i in 1 2 3 4 5; do
		curl -s -m 3 http://node1/ | grep -q 'node1 web page' && return 0
		sleep 2
	done
	return 1
}

task 1 "HTTP and 8080/tcp open on the web servers, now and permanently"
need "firewalld is running on node1" 'in_node node1 systemctl is-active --quiet firewalld'
need "curl http://node1/ gets the page from this VM" web
need "node1 allows the http service, now and permanently" fw node1 services http
need "node1 allows 8080/tcp, now and permanently" fw node1 ports 8080/tcp

task 2 "9090/tcp added with permanent only, then live after a reload"
need "node1 allows 9090/tcp, now and permanently" fw node1 ports 9090/tcp

task 3 "mysql allowed on the database servers by the firewall system role"
need "firewalld is running on node2" 'in_node node2 systemctl is-active --quiet firewalld'
need "node2 allows the mysql service, now and permanently" fw node2 services mysql
