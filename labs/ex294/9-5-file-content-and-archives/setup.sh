# The control node: ansible-core and greg's project, with a key the nodes
# already accept.
pkg_installed ansible-core || { echo ansible-core >>"$LAB_STATE/missing"; pkg_install ansible-core; }
user_add greg
install -d -m 700 -o greg -g greg /home/greg/.ssh
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
printf '[webservers]\nnode1\n\n[dbservers]\nnode2\n' >/home/greg/ansible/inventory
chown greg: /home/greg/ansible/ansible.cfg /home/greg/ansible/inventory

# The managed nodes, prepared as in chapter 3.1: devops with greg's key and
# passwordless sudo.
nodes_up 2
for n in $(nodes_names); do
	in_node -i "$n" 'useradd -m devops && install -d -m 700 -o devops -g devops /home/devops/.ssh &&
		cat >/home/devops/.ssh/authorized_keys && chown devops: /home/devops/.ssh/authorized_keys &&
		chmod 600 /home/devops/.ssh/authorized_keys &&
		echo "devops ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/devops && chmod 440 /etc/sudoers.d/devops' \
		</home/greg/.ssh/id_ed25519.pub
done
# What's installed here now; reset removes what the tasks add.
rpm -qa --qf '%{NAME}\n' | sort -u >"$LAB_STATE/rpms"

# Task 1: each node's sshd_config says something different about root.
in_node node1 'printf "\n# Set by hand\nPermitRootLogin yes\n" >>/etc/ssh/sshd_config'
in_node node2 'sed -i "s/^#PermitRootLogin .*/PermitRootLogin prohibit-password/" /etc/ssh/sshd_config'
for n in $(nodes_names); do
	in_node "$n" 'sshd -t && systemctl restart sshd'
	# Task 2: a message of the day to add to.
	in_node "$n" "printf '%s, a practice node\n' $n >/etc/motd"
done
nodes_wait 60
