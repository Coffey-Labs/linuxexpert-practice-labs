nodes_wait 60 || true
# ans CMD: run CMD as greg in his project directory.
ans() { timeout 300 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
OUT=$LAB_STATE/check.out
# user_ok NODE USER UID GROUP: USER has UID and is in GROUP on NODE.
user_ok() {
	[ "$(in_node "$1" id -u "$2")" = "$3" ] && in_node "$1" id -nG "$2" | tr ' ' '\n' | grep -qx "$4"
}
# pw_ok NODE USER: USER's password hash on NODE is that of Redhat123.
pw_ok() {
	local h; h=$(in_node "$1" getent shadow "$2" | cut -d: -f2)
	[ -n "$h" ] && python3 -W ignore -c 'import crypt, sys
sys.exit(crypt.crypt("Redhat123", sys.argv[1]) != sys.argv[1])' "$h"
}

task 1 "Developers on the web servers in developers, managers on the database servers in opsmgr"
need "fred (UID 3001) is in developers on node1" 'user_ok node1 fred 3001 developers'
need "barney (UID 3003) is in developers on node1" 'user_ok node1 barney 3003 developers'
need "wilma (UID 3002) is in opsmgr on node2" 'user_ok node2 wilma 3002 opsmgr'
need "wilma isn't on node1, and fred and barney aren't on node2" '! in_node node1 id wilma && ! in_node node2 id fred && ! in_node node2 id barney'
for u in node1:fred node1:barney node2:wilma; do
	need "${u#*:} on ${u%:*} has a hashed password, Redhat123" "pw_ok ${u%:*} ${u#*:}"
done

task 2 "A second run of users.yml reports changed=0"
need "/home/greg/ansible/users.yml exists" '[ -f /home/greg/ansible/users.yml ]'
need "ansible-playbook users.yml reports changed=0 on both nodes" 'ans ansible-playbook users.yml >"$OUT"; grep -Eq "^node1 +: ok=" "$OUT" && grep -Eq "^node2 +: ok=" "$OUT" && ! grep -E " : ok=" "$OUT" | grep -Eq "(changed|unreachable|failed)=[1-9]"'

task 3 "The developers group may run any command with sudo, no password, from a validated drop-in"
need "a file in /etc/sudoers.d on node1 has a rule for %developers" "in_node node1 'grep -rqs \"^%developers\" /etc/sudoers.d'"
need "visudo -c on node1 finds no errors" 'in_node node1 visudo -cq'
need "sudo -n whoami as fred on node1 prints root" '[ "$(in_node node1 runuser -u fred -- sudo -n whoami)" = root ]'
rm -f "$OUT"
