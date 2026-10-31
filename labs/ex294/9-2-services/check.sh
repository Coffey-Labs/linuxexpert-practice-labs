nodes_wait 60 || true
# ans CMD: run CMD as greg in his project directory.
ans() { timeout 300 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
OUT=$LAB_STATE/check.out
# unchanged NODE...: the playbook run in $OUT reached every NODE and changed
# nothing anywhere.
unchanged() {
	local n
	for n in "$@"; do grep -Eq "^$n +: ok=" "$OUT" || return 1; done
	! grep -E " : ok=" "$OUT" | grep -Eq "(changed|unreachable|failed)=[1-9]"
}

task 1 "chronyd running and enabled, rpcbind stopped and masked"
need "chronyd is enabled and running on the control node" 'enabled chronyd && active chronyd'
for n in $(nodes_names); do
	need "chronyd is enabled on $n" "[ \"\$(in_node $n systemctl is-enabled chronyd)\" = enabled ]"
	need "rpcbind is masked on $n" "[ \"\$(in_node $n systemctl is-enabled rpcbind)\" = masked ]"
	need "rpcbind isn't running on $n" "! in_node $n systemctl is-active --quiet rpcbind"
done

task 2 "A oneshot hello.service on every node; hello.yml changes nothing on a second run"
for n in $(nodes_names); do
	need "hello.service on $n is a oneshot unit" "[ \"\$(in_node $n systemctl show -P Type hello.service)\" = oneshot ]"
	need "hello.service is enabled on $n" "[ \"\$(in_node $n systemctl is-enabled hello.service)\" = enabled ]"
	need "the journal on $n has \"hello from systemd\"" "in_node $n 'journalctl -q --no-pager' | grep -q 'hello from systemd'"
done
need "/home/greg/ansible/hello.yml exists" '[ -f /home/greg/ansible/hello.yml ]'
need "ansible-playbook hello.yml reports changed=0 on every node" 'ans ansible-playbook hello.yml >"$OUT"; unchanged node1 node2'

task 3 "node2 boots to multi-user.target; target.yml changes nothing on a second run"
need "systemctl get-default on node2 shows multi-user.target" '[ "$(in_node node2 systemctl get-default)" = multi-user.target ]'
need "/home/greg/ansible/target.yml exists" '[ -f /home/greg/ansible/target.yml ]'
need "ansible-playbook target.yml reports changed=0 on node2" 'ans ansible-playbook target.yml >"$OUT"; unchanged node2'
rm -f "$OUT"
