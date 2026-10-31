nodes_wait 60 || true
# ans DIR CMD: run CMD as greg in /home/greg/DIR.
ans() { local d=$1; shift; timeout 120 runuser -l greg -c "cd ~/$d && $*" </dev/null; }
P=/home/greg/ansible C=/home/greg/ansible/ansible.cfg
D=$(ans ansible ansible-config dump --only-changed 2>/dev/null)
OUT=$LAB_STATE/check.out Q="'"

task 1 "ansible.cfg: inventory, devops, roles, collections, sudo without a password"
need "$C exists" '[ -f "$C" ]'
need "ansible --version in $P names $C" 'ans ansible ansible --version | grep -qx "  config file = $C"'
need "the dump shows inventory $P/inventory from $C" 'grep -Fqx "DEFAULT_HOST_LIST($C) = [$Q$P/inventory$Q]" <<<"$D"'
need "the dump shows remote_user devops from $C" 'grep -Fqx "DEFAULT_REMOTE_USER($C) = devops" <<<"$D"'
need "the dump shows roles_path with $P/roles from $C" 'grep -F "DEFAULT_ROLES_PATH($C) = " <<<"$D" | grep -Fq "$Q$P/roles$Q"'
need "the dump shows collections_path with $P/collections from $C" 'grep -F "COLLECTIONS_PATHS($C) = " <<<"$D" | grep -Fq "$Q$P/collections$Q"'
need "the dump shows become True from $C" 'grep -Fqx "DEFAULT_BECOME($C) = True" <<<"$D"'
need "the become method is sudo" 'ans ansible ansible-config dump | grep -Eq "^DEFAULT_BECOME_METHOD\(.*\) = sudo$"'
need "the become user is root" 'ans ansible ansible-config dump | grep -Eq "^DEFAULT_BECOME_USER\(.*\) = root$"'
need "Ansible doesn't ask for the sudo password" '! grep -Eq "^DEFAULT_BECOME_ASK_PASS\(.*\) = True$" <<<"$D"'
need "ansible all -a whoami prints root for node1 and node2" 'ans ansible ansible all -o -a whoami >"$OUT"; for n in node1 node2; do grep -Eq "^$n .*\(stdout\) root$" "$OUT" || exit 1; done'

task 2 "forks = 10"
need "ansible-config dump in $P shows DEFAULT_FORKS = 10 from $C" 'ans ansible ansible-config dump | grep -Fqx "DEFAULT_FORKS($C) = 10"'

task 3 "Every setting in proj2's ansible.cfg takes effect"
C2=/home/greg/proj2/ansible.cfg
D2=$(ans proj2 ansible-config dump --only-changed 2>/dev/null)
need "the dump in proj2 shows remote_user devops from $C2" 'grep -Fqx "DEFAULT_REMOTE_USER($C2) = devops" <<<"$D2"'
need "the dump in proj2 still shows inventory, host_key_checking and forks 20 from $C2" 'grep -Fq "DEFAULT_HOST_LIST($C2) = " <<<"$D2" && grep -Fqx "HOST_KEY_CHECKING($C2) = False" <<<"$D2" && grep -Fqx "DEFAULT_FORKS($C2) = 20" <<<"$D2"'
need "$C2 has no misspelled remote_usr line left" '! grep -Eq "^[[:space:]]*remote_usr[[:space:]]*=" "$C2"'
rm -f "$OUT"
