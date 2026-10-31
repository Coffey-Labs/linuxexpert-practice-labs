# The control node: ansible-core and greg's project, but not sshpass (task 1).
for p in ansible-core sshpass; do pkg_installed $p || echo $p >>"$LAB_STATE/missing"; done
pkg_installed ansible-core || pkg_install ansible-core
user_add greg
install -d -m 755 -o greg -g greg /home/greg/ansible
cat >/home/greg/ansible/ansible.cfg <<'X'
[defaults]
inventory = inventory
remote_user = devops
host_key_checking = false

[privilege_escalation]
become = true
X
printf '[nodes]\nnode1\nnode2\n' >/home/greg/ansible/inventory
chown greg: /home/greg/ansible/ansible.cfg /home/greg/ansible/inventory

# The managed nodes.
nodes_up 2
