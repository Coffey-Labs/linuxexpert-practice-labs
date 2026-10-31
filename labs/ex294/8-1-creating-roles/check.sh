nodes_wait 60 || true
R=/home/greg/ansible/roles/apache
# page HOST [PORT]: the home page HOST serves, trying for up to 15 seconds.
page() { local i; for i in 1 2 3 4 5; do curl -sf -m 3 "http://$1:${2:-80}/" && return 0; sleep 2; done; return 1; }
# shows HOST [PORT]: that page has HOST's FQDN and address.
shows() { local p; p=$(page "$@") && grep -qF "$1.lab.example" <<<"$p" && grep -qF "$(node_addr "$1")" <<<"$p"; }

task 1 "Role apache: httpd, the firewall, a home page with the host's FQDN and address"
need "the role has roles/apache/tasks/main.yml" '[ -f $R/tasks/main.yml ]'
need "the role has a template in roles/apache/templates" 'ls $R/templates/*.j2'
for n in node1 node2; do
	need "httpd is enabled and running on $n" "in_node $n 'systemctl is-enabled httpd && systemctl is-active httpd'"
	need "firewalld is running on $n" "in_node $n firewall-cmd --state"
done
need "curl http://node1/ shows node1.lab.example and 10.99.1.11" 'shows node1'
need "curl http://node2/ (or :8080 after task 2) shows node2.lab.example and 10.99.1.12" 'shows node2 || shows node2 8080'

task 2 "A default port of 80, and 8080 for node2"
need "roles/apache/defaults/main.yml sets a port variable to 80" 'grep -Eq "^[a-z_]*port[a-z_]*: *[\"'"'"']?80[\"'"'"']? *$" $R/defaults/main.yml'
need "curl http://node2:8080/ shows node2's page" 'shows node2 8080'
need "node1 serves its page on port 80, and nothing on 8080" 'shows node1 && ! curl -s -m 3 http://node1:8080/'

task 3 "include_role only on hosts with at least 2 GiB of memory"
need "a playbook in /home/greg/ansible uses include_role with a when" 'grep -lE "include_role" /home/greg/ansible/*.yml | xargs grep -lE "^[[:space:]]*when:"'
need "httpd is not installed on node3, which has 1 GiB" '! in_node node3 rpm -q httpd'
need "httpd is installed on node1 and node2, with 4 GiB" 'in_node node1 rpm -q httpd && in_node node2 rpm -q httpd'
