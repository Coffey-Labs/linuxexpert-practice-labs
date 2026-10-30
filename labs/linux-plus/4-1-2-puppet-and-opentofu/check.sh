F=/tmp/puppet-lab.txt T=/root/tofu
os_name() { /opt/puppetlabs/bin/facter os.name 2>/dev/null; }
tf_resources() { python3 -c 'import json, sys; print(len(json.load(open(sys.argv[1]))["resources"]))' "$1" 2>/dev/null; }

task 1 "Puppet manages /tmp/puppet-lab.txt"
need "openvox-agent is installed" 'pkg_installed openvox-agent && [ -x /opt/puppetlabs/bin/puppet ]'
need "~/lab.pp manages /tmp/puppet-lab.txt" 'grep -q "file.*/tmp/puppet-lab.txt" /root/lab.pp'
need "/tmp/puppet-lab.txt says Managed by Puppet on the OS name" '[ -n "$(os_name)" ] && [ "$(cat "$F")" = "Managed by Puppet on $(os_name)" ]'
need "/tmp/puppet-lab.txt has mode 644" '[ "$(stat -c %a "$F")" = 644 ]'

task 2 "OpenTofu applied terraform_data.hello, then destroyed it"
need "tofu is installed" 'command -v tofu'
need "~/tofu/main.tf has terraform_data hello" 'grep -Eq "resource +\"terraform_data\" +\"hello\"" "$T/main.tf"'
need "the state was applied (the backup state has the resource)" '[ "$(tf_resources "$T/terraform.tfstate.backup")" -ge 1 ] || [ "$(tf_resources "$T/terraform.tfstate")" -ge 1 ]'
need "it was destroyed again (the state has no resources)" '[ "$(tf_resources "$T/terraform.tfstate")" = 0 ]'
