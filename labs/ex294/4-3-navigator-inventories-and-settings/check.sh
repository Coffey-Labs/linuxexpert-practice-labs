nodes_wait 60 || true
# ans CMD: run CMD as greg in his project directory.
ans() { timeout 300 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
OUT=$LAB_STATE/check.out
C=/home/greg/ansible/ansible.cfg

task 1 "ansible-navigator inventory --graph matches ansible-inventory --graph"
need "ansible-inventory --graph works" 'ans ansible-inventory --graph >"$OUT.a" && grep -q node1 "$OUT.a"'
need "ansible-navigator inventory -m stdout --graph prints the same groups" 'ans ansible-navigator inventory -m stdout --graph >"$OUT.n" && diff -q "$OUT.a" "$OUT.n"'

task 2 "ansible-navigator uses the project's ansible.cfg"
ans ansible-navigator config dump --only-changed -m stdout >"$OUT.cfg" 2>/dev/null
need "the config dump shows CONFIG_FILE() = $C" 'grep -Fqx "CONFIG_FILE() = $C" "$OUT.cfg"'

task 3 "roles_path outside the project, mounted into the execution environment"
need "$C sets roles_path to /home/greg/roles" 'ans ansible-config dump --only-changed | grep -F "DEFAULT_ROLES_PATH($C) = " | grep -q "/home/greg/roles\b"'
need "the execution environment mounts /home/greg/roles" 'ans ansible-navigator settings --effective -m stdout | python3 -c "import sys, yaml
m = yaml.safe_load(sys.stdin)[\"ansible-navigator\"][\"execution-environment\"].get(\"volume-mounts\") or []
sys.exit(not any(str(v.get(\"src\", \"\")).rstrip(\"/\") == \"/home/greg/roles\" for v in m))"'
need "ansible-navigator finds the banner role (banner.yml --syntax-check)" 'ans ansible-navigator run banner.yml --syntax-check -m stdout'
for n in $(nodes_names); do
	need "$n has /etc/motd.d/banner from the role" "in_node $n grep -q 'managed by Ansible' /etc/motd.d/banner"
done
rm -f "$OUT".*
