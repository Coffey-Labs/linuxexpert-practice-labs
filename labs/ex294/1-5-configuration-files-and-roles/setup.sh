# The control node: ansible-core and greg's project, with an inventory.
pkg_installed ansible-core || { echo ansible-core >>"$LAB_STATE/missing"; pkg_install ansible-core; }
user_add greg
install -d -m 700 -o greg -g greg /home/greg/.ssh
runuser -u greg -- ssh-keygen -q -t ed25519 -N '' -f /home/greg/.ssh/id_ed25519
install -d -m 755 -o greg -g greg /home/greg/ansible
cat >/home/greg/ansible/ansible.cfg <<'EOF'
[defaults]
inventory = inventory
remote_user = ansible
host_key_checking = false
EOF
printf '[nodes]
node1
node2
' >/home/greg/ansible/inventory
chown greg: /home/greg/ansible/ansible.cfg /home/greg/ansible/inventory

# The managed nodes, with an empty /etc/motd (task 3).
nodes_up 2
# greg's key goes to ansible on every node, and ansible may use sudo without
# a password.
for n in $(nodes_names); do
	in_node -i "$n" 'install -d -m 700 -o ansible -g ansible /home/ansible/.ssh &&
		install -m 600 -o ansible -g ansible /dev/stdin /home/ansible/.ssh/authorized_keys &&
		echo "ansible ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/ansible &&
		chmod 440 /etc/sudoers.d/ansible' </home/greg/.ssh/id_ed25519.pub
done
for n in $(nodes_names); do in_node "$n" ': >/etc/motd'; done
