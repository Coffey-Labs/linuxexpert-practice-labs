nodes_wait 60 || true
# ans CMD: run CMD as greg in his project directory.
ans() { timeout 300 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
OUT=$LAB_STATE/check.out
# sshd_start NODE: when sshd's main process started there.
sshd_start() { in_node "$1" systemctl show -P ExecMainStartTimestampMonotonic sshd; }
# tarball FILE: a bzip2 tar file with an etc/passwd in it.
TARPY='import sys, tarfile
t = tarfile.open(sys.argv[1], "r:bz2")
sys.exit(not any(m.name.endswith("etc/passwd") or m.name == "passwd" for m in t.getmembers()))'
# The block task 2 asks for, as it should be after the later run.
BLOCK='This node is managed by Ansible.
Changes made by hand will be lost.
Questions: admin@lab.example'

task 1 "PermitRootLogin no in sshd_config on every node; sshd.yml restarts nothing on a second run"
for n in $(nodes_names); do
	need "/etc/ssh/sshd_config on $n has one PermitRootLogin line" "[ \"\$(in_node $n grep -c ^PermitRootLogin /etc/ssh/sshd_config)\" = 1 ]"
	need "it says PermitRootLogin no on $n" "in_node $n grep -qx 'PermitRootLogin no' /etc/ssh/sshd_config"
	need "sshd on $n accepts its configuration and is running" "in_node $n 'sshd -t && systemctl is-active --quiet sshd'"
done
need "/home/greg/ansible/sshd.yml exists" '[ -f /home/greg/ansible/sshd.yml ]'
B1=$(sshd_start node1) B2=$(sshd_start node2)
need "ansible-playbook sshd.yml reports changed=0 on both nodes" 'ans ansible-playbook sshd.yml >"$OUT"; grep -Eq "^node1 +: ok=" "$OUT" && grep -Eq "^node2 +: ok=" "$OUT" && ! grep -E " : ok=" "$OUT" | grep -Eq "(changed|unreachable|failed)=[1-9]"'
need "the second run didn't restart sshd" '[ -n "$B1" ] && [ "$(sshd_start node1)" = "$B1" ] && [ "$(sshd_start node2)" = "$B2" ]'

task 2 "One marked three-line block in /etc/motd, with the changed line"
for n in $(nodes_names); do
	need "/etc/motd on $n has one BEGIN and one END marker" "[ \"\$(in_node $n grep -c BEGIN /etc/motd)\" = 1 ] && [ \"\$(in_node $n grep -c END /etc/motd)\" = 1 ]"
	need "the block on $n has the three lines, with Questions: admin@lab.example" "[ \"\$(in_node $n cat /etc/motd | sed -n '/BEGIN/,/END/p' | sed '1d;\$d')\" = \"\$BLOCK\" ]"
	need "/etc/motd on $n still starts with its own line" "in_node $n head -1 /etc/motd | grep -qx '$n, a practice node'"
done

task 3 "/etc archived as /root/etc.tar.bz2 on every node, fetched to backups/"
for n in $(nodes_names); do
	need "/root/etc.tar.bz2 on $n is a bzip2 tar file of /etc" "in_node $n python3 -c '$TARPY' /root/etc.tar.bz2"
	need "/home/greg/ansible/backups/$n/root/etc.tar.bz2 is a copy of it" "python3 -c '$TARPY' /home/greg/ansible/backups/$n/root/etc.tar.bz2"
done
rm -f "$OUT"
