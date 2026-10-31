inv=/root/ansible/inventory

task 1 "The service on port 7070 is off, now and at boot"
need "nothing listens on port 7070" '! listening 7070 tcp'
need "le-lab-oldapp.service doesn't start at boot" '! enabled le-lab-oldapp.service'

task 2 "A runbook for restarting nginx" self

task 3 "/root/add-dev.sh run for erin"
need "/root/add-dev.sh is an executable script" '[ -x /root/add-dev.sh ] && head -n1 /root/add-dev.sh | grep -q "^#!"'
need "user erin exists" 'id erin'
need "erin is in group developers" 'id -nG erin | grep -qw developers'
need "/srv/erin is a directory owned by erin" '[ -d /srv/erin ] && [ "$(stat -c %U /srv/erin)" = erin ]'

task 4 "Ansible installed nginx from /root/ansible/playbook.yml"
need "ansible-playbook is installed" 'command -v ansible-playbook'
need "/root/ansible/inventory has a [webservers] group" 'grep -qx "[[:space:]]*\[webservers\][[:space:]]*" $inv'
need "the inventory has localhost ansible_connection=local" 'grep -Eq "^[[:space:]]*localhost[[:space:]]+ansible_connection=local" $inv'
need "/root/ansible/playbook.yml runs on hosts webservers" 'grep -Eq "hosts:[[:space:]]*\"?webservers" /root/ansible/playbook.yml'
need "nginx is installed" 'command -v nginx'
need "nginx starts at boot" enabled nginx
need "nginx is running" active nginx
