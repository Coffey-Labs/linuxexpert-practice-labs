# The control node: ansible-core, sshpass (for -k) and greg's project, but
# no key for greg (task 1).
for p in ansible-core sshpass; do pkg_installed $p || echo $p >>"$LAB_STATE/missing"; done
pkg_installed ansible-core || pkg_install ansible-core
pkg_installed sshpass || pkg_install sshpass
user_add greg
install -d -m 755 -o greg -g greg /home/greg/ansible
cat >/home/greg/ansible/ansible.cfg <<'C'
[defaults]
inventory = inventory
remote_user = devops
host_key_checking = false

[privilege_escalation]
become = true
C
printf '[nodes]\nnode1\nnode2\n' >/home/greg/ansible/inventory
chown greg: /home/greg/ansible/ansible.cfg /home/greg/ansible/inventory

# The managed nodes, with devops (password and sudo, but no keys).
nodes_up 2
for n in $(nodes_names); do
	in_node "$n" 'id devops >/dev/null 2>&1 || useradd -m devops
		echo devops:Lab-Pass-1 | chpasswd
		echo "devops ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/devops
		chmod 440 /etc/sudoers.d/devops
		rm -rf /home/devops/.ssh'
done
