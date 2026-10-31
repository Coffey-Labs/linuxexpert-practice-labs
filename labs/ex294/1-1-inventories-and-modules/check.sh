nodes_wait 60 || true
# ans CMD: run CMD as greg in his project directory.
ans() { timeout 180 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
OUT=$LAB_STATE/check.out
# members GROUP: the hosts in GROUP and its child groups, sorted, on one line.
members() {
	ans ansible-inventory -i inventory --list 2>/dev/null | python3 -c 'import json, sys
d = json.load(sys.stdin)
def hosts(g):
    v = d.get(g, {})
    return set(v.get("hosts", [])).union(*[hosts(c) for c in v.get("children", [])])
print(" ".join(sorted(hosts(sys.argv[1]))))' "$1"
}
under_all() { ans ansible-inventory -i inventory --list 2>/dev/null | python3 -c 'import json, sys
sys.exit(0 if {"webservers", "dbservers"} <= set(json.load(sys.stdin)["all"].get("children", [])) else 1)'; }
answer_has() { grep -qw "$2" "/root/lab-answers/$1" 2>/dev/null; }

task 1 "An inventory with node1 and node2 in webservers and node3 in dbservers"
need "/home/greg/ansible/inventory exists" '[ -e /home/greg/ansible/inventory ]'
need "webservers holds node1 and node2, and only those" '[ "$(members webservers)" = "node1 node2" ]'
need "dbservers holds node3, and only it" '[ "$(members dbservers)" = node3 ]'
need "both groups are directly under @all" under_all

task 2 "Every host answers the ping module"
need "ansible all -m ping gets pong from node1, node2 and node3" 'ans ansible all -o -m ansible.builtin.ping >"$OUT"; for n in node1 node2 node3; do grep -Eq "^$n \| SUCCESS.*pong" "$OUT" || exit 1; done'

task 3 "tree on the webservers, and only there"
need "tree is installed on node1" 'in_node node1 rpm -q tree'
need "tree is installed on node2" 'in_node node2 rpm -q tree'
need "tree is not installed on node3, which isn't a webserver" '! in_node node3 rpm -q tree'

task 4 "The hosts matched by all:!dbservers, in /root/lab-answers/4"
need "/root/lab-answers/4 names node1 and node2" 'answer_has 4 node1 && answer_has 4 node2'
need "/root/lab-answers/4 doesn't name node3" '! answer_has 4 node3'
rm -f "$OUT"
