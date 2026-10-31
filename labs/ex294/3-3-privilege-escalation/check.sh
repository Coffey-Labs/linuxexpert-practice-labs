nodes_wait 60 || true
# ans CMD: run CMD as greg in his project directory.
ans() { setsid -w timeout 180 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
OUT=$LAB_STATE/check.out
P='-e ansible_password=Lab-Pass-1 -e ansible_become_password=Lab-Pass-1'
A=/home/greg/ansible
# sudo_ok NODE: devops's drop-in is valid, mode 0440, and gives NOPASSWD: ALL.
sudo_ok() {
	in_node "$1" 'visudo -cf /etc/sudoers.d/devops && [ "$(stat -c %a /etc/sudoers.d/devops)" = 440 ] &&
		sudo -l -U devops | grep -q "NOPASSWD: ALL" && runuser -u devops -- sudo -n true'
}
idroot() { ans ansible all -o -a id >"$OUT" && grep -q . "$OUT" && ! grep -v "uid=0(root)" "$OUT"; }

task 1 "Passwordless sudo for devops from a validated drop-in, mode 0440"
need "/home/greg/ansible/sudo.yml exists" "[ -f $A/sudo.yml ]"
need "sudo.yml validates the file with visudo" "grep -Eq 'validate:.*visudo' $A/sudo.yml"
for n in $(nodes_names); do
	need "/etc/sudoers.d/devops on $n is valid, mode 0440, and gives devops NOPASSWD: ALL" "sudo_ok $n"
done
need "ansible all -a id shows uid=0(root) on every node (as greg, in ~/ansible)" idroot

task 2 "typo.yml fails at validate, and sudo still works"
need "/home/greg/ansible/typo.yml exists" "[ -f $A/typo.yml ]"
need "typo.yml validates the file with visudo" "grep -Eq 'validate:.*visudo' $A/typo.yml"
need "running typo.yml fails with \"failed to validate\"" "! ans ansible-playbook typo.yml $P >\"\$OUT\" && grep -q 'failed to validate' \"\$OUT\""
for n in $(nodes_names); do
	need "devops still has passwordless sudo on $n" "sudo_ok $n"
done
need "ansible all -a id still shows uid=0(root) on every node" idroot

task 3 "whoami.yml runs whoami as devops in a play that becomes root"
need "/home/greg/ansible/whoami.yml exists" "[ -f $A/whoami.yml ]"
need "whoami.yml has become: true and become_user: devops" "grep -Eq '^ *become: *(true|yes|True)' $A/whoami.yml && grep -Eq '^ *become_user: *[\"'\'']?devops' $A/whoami.yml"
need "whoami.yml runs whoami" "grep -q whoami $A/whoami.yml"
need "running whoami.yml -v shows whoami printing devops on every node, with no failures" 'ans ansible-playbook whoami.yml -v >"$OUT" && for n in $(nodes_names); do grep -E "^(ok|changed): \[$n\] => \{.*\"stdout\": \"devops\"" "$OUT" >/dev/null || exit 1; done'
rm -f "$OUT"
