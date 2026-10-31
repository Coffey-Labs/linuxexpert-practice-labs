nodes_wait 60 || true
# ans CMD: run CMD as greg in his project directory.
ans() { setsid -w timeout 180 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
OUT=$LAB_STATE/check.out
A=/home/greg/ansible
# recap0: every node in $OUT's recap has changed=0 and no failures.
recap0() { grep -Eq "^node[0-9]+ +: ok=" "$OUT" && ! grep -E " : ok=" "$OUT" | grep -Eq "(changed|unreachable|failed)=[1-9]"; }
# blocks NODE: the "ok: [NODE] ... => {" ... "}" blocks of debug output in $OUT.
blocks() { awk -v n="$1" 'index($0, "ok: [" n "] =>") == 1 && / => \{$/ {f=1} f {print} /^}/ {f=0}' "$OUT"; }

task 1 "df.yml prints the second line of df -h / on every node, reporting ok"
need "/home/greg/ansible/df.yml exists and uses stdout_lines[1]" "[ -f $A/df.yml ] && grep -qF 'stdout_lines[1]' $A/df.yml"
need "running df.yml reports changed=0 and no failures" 'ans ansible-playbook df.yml >"$OUT"; recap0'
for n in $(nodes_names); do
	need "df.yml prints $n's root file system line (... NN% /)" "blocks $n | grep -Eq '\": \"[^ \"]+ +[0-9.,]+[A-Z]? +[0-9.,]+[A-Z]? +[0-9.,]+[A-Z]? +[0-9]+% /\"'"
done

task 2 "/root/hostinfo.txt on each node holds its own hostnamectl output"
for n in $(nodes_names); do
	need "/root/hostinfo.txt on $n has hostnamectl's output for $n" "in_node $n grep -Eq 'Static hostname: *$n\$' /root/hostinfo.txt"
	need "it has the rest of the output too" "in_node $n grep -q 'Operating System:' /root/hostinfo.txt"
done

task 3 "enabled.yml prints each of three services with its is-enabled result"
need "/home/greg/ansible/enabled.yml exists and runs systemctl is-enabled" "[ -f $A/enabled.yml ] && grep -q 'is-enabled' $A/enabled.yml"
need "running enabled.yml has no failures" 'ans ansible-playbook enabled.yml >"$OUT" && grep -Eq "^node[0-9]+ +: ok=" "$OUT"'
for n in $(nodes_names); do
	need "on $n, it prints at least three lines labeled (item=SERVICE)" "[ \"\$(grep -E '^ok: \\[$n\\] => \\(item=[A-Za-z0-9_.@-]+\\) => \\{\$' \"\$OUT\" | sort -u | wc -l)\" -ge 3 ]"
	need "the printed lines for $n give the results (enabled, disabled, ...)" "blocks $n | grep -Eq '(enabled|disabled|static|masked|indirect|generated|alias|linked|not-found)'"
done
rm -f "$OUT"
