nodes_wait 60 || true
# ans CMD: run CMD as greg in his project directory.
ans() { timeout 300 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
P=/home/greg/ansible
OUT=$LAB_STATE/check.out
# url: the ansible.posix tarball URL on node1 that a requirements file in
# the project installs with type: url.
url() { local f
	for f in $(grep -rlE 'type: *["'"'"']?url' $P --include='*.yml' --include='*.yaml' --exclude-dir=ansible_collections); do
		grep -oE 'https?://(node1|node1\.lab\.example|10\.99\.1\.11)/[^ "'"'"']*ansible-posix-[^ "'"'"']*\.tar\.gz' "$f"
	done | head -n1; }

task 1 "ansible.posix: a tarball on node1, installed into the project with type: url"
need "a requirements file in $P installs an ansible-posix tarball from node1 with type: url" '[ -n "$(url)" ]'
need "node1 serves that tarball" 'curl -sf -m 10 "$(url)" | tar -tz 2>/dev/null | grep -qx MANIFEST.json'
need "ansible.posix is installed in $P/collections" '[ -f $P/collections/ansible_collections/ansible/posix/MANIFEST.json ]'
need "ansible-galaxy collection list shows it under the project's collections directory" 'ans ansible-galaxy collection list ansible.posix 2>/dev/null | grep -qx "# $P/collections/ansible_collections"'

task 2 "community.general for this ansible-core, and ini.yml using ini_file"
need "ansible-doc community.general.ini_file works" 'ans ansible-doc community.general.ini_file >"$OUT" 2>&1 && grep -q "^> COMMUNITY.GENERAL.INI_FILE" "$OUT"'
need "the installed community.general supports this ansible-core (no \"does not support\" warning)" '! grep -q "does not support Ansible version" "$OUT"'
need "/home/greg/ansible/ini.yml exists and uses community.general" 'grep -q "community\.general" $P/ini.yml'
need "ansible-playbook ini.yml runs without failures" 'ans ansible-playbook ini.yml >"$OUT" 2>&1; grep -Eq "^node1 +: ok=" "$OUT" && ! grep -E " : ok=" "$OUT" | grep -Eq "(unreachable|failed)=[1-9]"'
need "node1's /etc/lab.ini has port = 8080 in [web]" "in_node node1 python3 -c 'import configparser, sys; c = configparser.ConfigParser(); c.read(\"/etc/lab.ini\"); sys.exit(c.get(\"web\", \"port\", fallback=\"\") != \"8080\")'"

task 3 "community.crypto installed with -p outside collections_path"
need "community.crypto is installed in /home/greg/elsewhere" '[ -f /home/greg/elsewhere/ansible_collections/community/crypto/MANIFEST.json ]'
need "Ansible can't find its modules: ansible-doc community.crypto.openssl_privatekey fails" '! ans ansible-doc community.crypto.openssl_privatekey 2>/dev/null | grep -q "^> COMMUNITY.CRYPTO.OPENSSL_PRIVATEKEY"'
rm -f "$OUT"
