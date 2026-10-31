# The control node: ansible-core, and greg with an SSH key and his project.
pkg_installed ansible-core || { echo ansible-core >>"$LAB_STATE/missing"; pkg_install ansible-core; }
user_add greg
runuser -u greg -- ssh-keygen -q -t ed25519 -N '' -f /home/greg/.ssh/id_ed25519
install -d -m 755 -o greg -g greg /home/greg/ansible
cat >/home/greg/ansible/ansible.cfg <<'X'
[defaults]
inventory = inventory
remote_user = devops
host_key_checking = false

[privilege_escalation]
become = true
X
printf '[webservers]\nnode1\nnode2\n' >/home/greg/ansible/inventory
chown greg: /home/greg/ansible/ansible.cfg /home/greg/ansible/inventory

# The managed nodes, each with devops: greg's key and passwordless sudo.
nodes_up 2
for n in $(nodes_names); do
	in_node $n 'useradd -m devops && echo "devops ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/devops && chmod 440 /etc/sudoers.d/devops && install -d -m 700 -o devops -g devops /home/devops/.ssh'
	in_node -i $n 'install -m 600 -o devops -g devops /dev/stdin /home/devops/.ssh/authorized_keys' </home/greg/.ssh/id_ed25519.pub
done

# The web servers: httpd running with its stock configuration.
for n in $(nodes_names); do
	in_node $n 'dnf -y -q install httpd >/dev/null && systemctl enable --now --quiet httpd'
done

# Ready to go: greg reaches every node as root.
timeout 120 runuser -l greg -c 'cd ~/ansible && ansible all -o -a id' </dev/null | grep -c 'uid=0(root)' | grep -qx 2
