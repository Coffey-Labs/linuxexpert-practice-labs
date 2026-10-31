nodes_wait 60 || true
# ans CMD: run CMD as greg in his project directory.
ans() { timeout 180 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
OUT=$LAB_STATE/check.out
# hashed NODE: devops has a password hash there, not a lock or nothing.
hashed() { in_node "$1" getent shadow devops | cut -d: -f2 | grep -q '^\$'; }

task 1 "devops on every node: hashed password, passwordless sudo, greg's key"
for n in $(nodes_names); do
	need "user devops exists on $n" "in_node $n id devops"
	need "devops has a hashed password on $n" hashed $n
	need "devops may run any command with sudo and no password on $n" "in_node $n 'sudo -l -U devops' | grep -q 'NOPASSWD: ALL'"
	need "greg logs in to $n as devops with his key" "timeout 20 runuser -u greg -- ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 devops@$n true"
done
need "ansible all -m ping works without -k (as greg, in ~/ansible)" 'ans ansible all -m ping'
need "ansible all -a id shows uid=0(root) on every host" 'ans ansible all -o -a id >"$OUT" && grep -q . "$OUT" && ! grep -v "uid=0(root)" "$OUT"'

task 2 "A second run of bootstrap.yml reports changed=0 on every node"
need "/home/greg/ansible/bootstrap.yml exists" '[ -f /home/greg/ansible/bootstrap.yml ]'
need "ansible-playbook bootstrap.yml reports changed=0 and no failures" 'ans ansible-playbook bootstrap.yml -e ansible_password=Lab-Pass-1 -e ansible_become_password=Lab-Pass-1 >"$OUT"; grep -Eq "^node[0-9]+ +: ok=" "$OUT" && ! grep -E " : ok=" "$OUT" | grep -Eq "(changed|unreachable|failed)=[1-9]"'

task 3 "One inventory host is reached by address, with ansible_host"
H=$(ans ansible-inventory --list 2>/dev/null | python3 -c 'import sys, json, re
d = json.load(sys.stdin)
print(next((h for h, v in d.get("_meta", {}).get("hostvars", {}).items() if re.fullmatch(r"\d+(\.\d+){3}", str(v.get("ansible_host", "")))), ""))' 2>/dev/null)
need "an inventory host has ansible_host set to an IPv4 address" '[ -n "$H" ]'
need "ansible $H -m ping works" 'ans ansible "$H" -m ping'
rm -f "$OUT"
