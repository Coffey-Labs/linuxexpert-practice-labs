nodes_wait 60 || true
# ans CMD: run CMD as greg in his project directory.
ans() { timeout 300 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
OUT=$LAB_STATE/check.out
D=/etc/ssh/sshd_config.d/50-lab.conf
# What each node should report: memory in MiB, vdb and vdd.
declare -A MEM=([node1]=4096 [node2]=2048 [node3]=1024)
declare -A VDB=([node1]="2.00 GB" [node2]="2.00 GB" [node3]=NONE)
declare -A VDD=([node1]="1.00 GB" [node2]=NONE [node3]=NONE)
# The BIOS version as Ansible sees it (the VM's, on every node).
BIOS=$(ans "ansible node1 -m setup -a filter=ansible_bios_version" 2>/dev/null | sed -n 's/^ *"ansible_bios_version": "\(.*\)",\{0,1\}$/\1/p')
# line NODE FILE TEXT: FILE on NODE has the line TEXT (spaces at the end aside).
line() { in_node "$1" cat "$2" | sed 's/[[:space:]]*$//' | grep -qxF "$3"; }

task 1 "/etc/myhosts on the database servers: every node's address, FQDN and name"
need "node3 has /etc/myhosts" 'in_node node3 test -f /etc/myhosts'
for n in node1 node2 node3; do
	need "node3's /etc/myhosts has \"$(node_addr $n) $n.lab.example $n\"" "in_node node3 cat /etc/myhosts | awk -v a=$(node_addr $n) -v n=$n '\$1 == a && \$2 == n \".lab.example\" && \$3 == n && NF == 3 { ok = 1 } END { exit !ok }'"
done
need "it has one line per node" '[ "$(in_node node3 grep -c "^10\.99\.1\." /etc/myhosts)" = 3 ]'
need "node1 and node2, the web servers, have no /etc/myhosts" '! in_node node1 test -e /etc/myhosts && ! in_node node2 test -e /etc/myhosts'

task 2 "/root/hwreport.txt on every node, with NONE for a missing disk"
need "Ansible reports the BIOS version" '[ -n "$BIOS" ]'
for n in node1 node2 node3; do
	need "$n has /root/hwreport.txt" "in_node $n test -f /root/hwreport.txt"
	need "$n's report says HOST=$n" "line $n /root/hwreport.txt HOST=$n"
	need "$n's report says MEMORY=${MEM[$n]}" "line $n /root/hwreport.txt MEMORY=${MEM[$n]}"
	need "$n's report says BIOS=$BIOS" 'line '$n' /root/hwreport.txt "BIOS=$BIOS"'
	need "$n's report says DISK_SIZE_VDB=${VDB[$n]}" "line $n /root/hwreport.txt 'DISK_SIZE_VDB=${VDB[$n]}'"
	need "$n's report says DISK_SIZE_VDD=${VDD[$n]}" "line $n /root/hwreport.txt 'DISK_SIZE_VDD=${VDD[$n]}'"
done

task 3 "sshd.yml: a validated sshd drop-in that keeps the old file on a bad value"
need "/home/greg/ansible/sshd.yml exists" '[ -f /home/greg/ansible/sshd.yml ]'
need "ansible-playbook sshd.yml runs without failures" 'ans ansible-playbook sshd.yml >"$OUT"; grep -Eq "^node[0-9]+ +: ok=" "$OUT" && ! grep -E " : ok=" "$OUT" | grep -Eq "(unreachable|failed)=[1-9]"'
for n in node1 node2 node3; do
	need "$n's $D says PermitRootLogin no" "line $n $D 'PermitRootLogin no'"
done
need "with -e sshd_root_login=maybe, the task fails with \"failed to validate\"" 'in_node node1 md5sum $D >"$OUT.sum"; ans ansible-playbook sshd.yml -e sshd_root_login=maybe >"$OUT"; grep -q "failed to validate" "$OUT" && grep -Eq "^node1 +: .*failed=1" "$OUT"'
need "and node1's $D is unchanged" '[ "$(in_node node1 md5sum $D)" = "$(cat "$OUT.sum")" ]'
rm -f "$OUT" "$OUT.sum"
