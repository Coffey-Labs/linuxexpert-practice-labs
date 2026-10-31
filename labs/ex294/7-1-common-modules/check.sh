nodes_wait 60 || true
# ans CMD: run CMD as greg in his project directory.
ans() { setsid -w timeout 300 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
OUT=$LAB_STATE/check.out
A=/home/greg/ansible
# recap0: every node in $OUT's recap has changed=0 and no failures.
recap0() { grep -Eq "^node[0-9]+ +: ok=" "$OUT" && ! grep -E " : ok=" "$OUT" | grep -Eq "(changed|unreachable|failed)=[1-9]"; }
# page: curl from the control node prints node1's home page (wait up to 15 s).
page() {
	local want i
	want=$(in_node node1 cat /var/www/html/index.html) && [ -n "$want" ] || return 1
	for i in $(seq 15); do
		[ "$(curl -s --max-time 3 http://node1/)" = "$want" ] && return 0
		sleep 1
	done
	return 1
}
fw() { in_node node1 firewall-cmd "$@"; }

task 1 "web.yml: httpd on node1 with a home page, through the firewall"
need "/home/greg/ansible/web.yml exists" "[ -f $A/web.yml ]"
need "httpd is installed, running and enabled on node1" "in_node node1 'rpm -q httpd && systemctl is-active httpd && systemctl is-enabled httpd'"
need "node1 has a home page, /var/www/html/index.html" "in_node node1 test -s /var/www/html/index.html"
need "firewalld is still running and enabled on node1" "in_node node1 'systemctl is-active firewalld && systemctl is-enabled firewalld'"
need "node1's firewall allows http permanently" "fw --permanent --query-service=http || fw --permanent --query-port=80/tcp"
need "curl http://node1/ on the control node prints the page" page
need "a second run of web.yml reports changed=0 and no failures" 'ans ansible-playbook web.yml >"$OUT"; recap0'

task 2 "dd.yml makes /root/swapfile with dd, only once"
need "/home/greg/ansible/dd.yml exists, with a dd command" "[ -f $A/dd.yml ] && grep -q 'dd ' $A/dd.yml"
for n in $(nodes_names); do
	need "/root/swapfile on $n is 16 MiB" "[ \"\$(in_node $n stat -c %s /root/swapfile)\" = 16777216 ]"
done
need "a second run of dd.yml reports changed=0 and leaves the files alone" 'before=$(for n in $(nodes_names); do in_node $n stat -c %Y /root/swapfile; done); ans ansible-playbook dd.yml >"$OUT"; recap0 && [ "$before" = "$(for n in $(nodes_names); do in_node $n stat -c %Y /root/swapfile; done)" ]'

task 3 "sshver.yml prints openssh-server's version on every node"
need "/home/greg/ansible/sshver.yml exists" "[ -f $A/sshver.yml ]"
need "sshver.yml doesn't run rpm" "! grep -Eq '(^|[^_a-z])rpm +-' $A/sshver.yml"
need "running sshver.yml prints each node's openssh-server version" 'ans ansible-playbook sshver.yml >"$OUT" || exit 1
	for n in $(nodes_names); do
		v=$(in_node $n rpm -q --qf "%{VERSION}" openssh-server)
		awk -v n="$n" "\$0 == \"ok: [\" n \"] => {\" {f=1} f {print} /^}/ {f=0}" "$OUT" | grep -qF "$v" || exit 1
	done'
rm -f "$OUT"
