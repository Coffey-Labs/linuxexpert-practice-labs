ans() { (cd /home/alice/ans 2>/dev/null && runuser -u alice -- env HOME=/home/alice "$@"); }
distro=$(. /etc/os-release; echo "$NAME" | awk '{print $1}')

task 1 "Ansible reaches 127.0.0.1 as alice over SSH"
need "ansible is installed" 'command -v ansible && command -v ansible-playbook'
need "~/ans/inventory.ini has group lab with 127.0.0.1" 'grep -qx "\[lab\]" /home/alice/ans/inventory.ini && grep -q "^127\.0\.0\.1" /home/alice/ans/inventory.ini'
need "ansible lab -m ping works as alice" 'ans timeout 60 ansible lab -i inventory.ini -m ping'

task 2 "site.yml installs tree, manages /etc/motd, runs atd"
need "~/ans/site.yml exists" '[ -s /home/alice/ans/site.yml ]'
need "tree is installed" 'pkg_installed tree'
need "/etc/motd says Managed by Ansible on $distro" 'grep -qx "Managed by Ansible on $distro.*" /etc/motd'
need "atd is running" active atd
need "atd starts at boot" enabled atd
