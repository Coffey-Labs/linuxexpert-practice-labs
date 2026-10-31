nodes_wait 60 || true
# ans CMD: run CMD as greg in his project directory.
ans() { setsid -w timeout 180 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
OUT=$LAB_STATE/check.out
K=/home/greg/.ssh/id_ed25519
# keyssh NODE: greg logs in to NODE as devops with his key and no password.
keyssh() {
	timeout 20 runuser -u greg -- ssh -i $K -o IdentitiesOnly=yes -o BatchMode=yes \
		-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 devops@"$1" true
}
# recap0: every node in $OUT's recap has changed=0 and no failures.
recap0() { grep -Eq "^node[0-9]+ +: ok=" "$OUT" && ! grep -E " : ok=" "$OUT" | grep -Eq "(changed|unreachable|failed)=[1-9]"; }

task 1 "An Ed25519 key pair for greg, no passphrase, mode 600"
need "/home/greg/.ssh/id_ed25519 and id_ed25519.pub exist" "[ -f $K ] && [ -f $K.pub ]"
need "the private key is mode 600" "[ \"\$(stat -c %a $K)\" = 600 ]"
need "it's an Ed25519 key" "ssh-keygen -l -f $K.pub | grep -q ED25519"
need "it has no passphrase" "ssh-keygen -y -P '' -f $K"

task 2 "keys.yml puts greg's key in devops's authorized_keys on every node"
need "/home/greg/ansible/keys.yml exists" '[ -f /home/greg/ansible/keys.yml ]'
for n in $(nodes_names); do
	need "greg's public key is in /home/devops/.ssh/authorized_keys on $n" "[ -f $K.pub ] && in_node $n cat /home/devops/.ssh/authorized_keys | grep -qF \"\$(cut -d' ' -f2 $K.pub)\""
	need "greg logs in to $n as devops with his key, no password" "keyssh $n"
done
need "a second run of keys.yml reports changed=0 and no failures" 'ans ansible-playbook keys.yml -e ansible_password=Lab-Pass-1 -e ansible_become_password=Lab-Pass-1 >"$OUT"; recap0'

task 3 "Host key checking on, with the nodes' keys in known_hosts"
need "ansible.cfg doesn't turn host key checking off" 'ans ansible-config dump | grep -E "^HOST_KEY_CHECKING" | grep -q "= True"'
for n in $(nodes_names); do
	need "greg's ~/.ssh/known_hosts has a host key for $n" "runuser -u greg -- ssh-keygen -F $n -f /home/greg/.ssh/known_hosts"
done
need "ansible all -m ping works with no prompt (as greg, in ~/ansible)" 'ans ansible all -m ping'
rm -f "$OUT"
