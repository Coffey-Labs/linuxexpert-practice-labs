# The control node: ansible-core, greg with a key, his project without an
# ansible.cfg (tasks 1 and 2), and proj2 with a misspelled setting (task 3).
pkg_installed ansible-core || { echo ansible-core >>"$LAB_STATE/missing"; pkg_install ansible-core; }
user_add greg
install -d -m 700 -o greg -g greg /home/greg/.ssh
runuser -u greg -- ssh-keygen -q -t ed25519 -N '' -f /home/greg/.ssh/id_ed25519
for d in ansible proj2; do
	install -d -m 755 -o greg -g greg /home/greg/$d
	printf '[nodes]\nnode1\nnode2\n' >/home/greg/$d/inventory
done
cat >/home/greg/proj2/ansible.cfg <<'X'
[defaults]
inventory = ./inventory
remote_usr = devops
host_key_checking = false
forks = 20
X
chown -R greg: /home/greg/ansible /home/greg/proj2

# The managed nodes, with devops: greg's key and passwordless sudo.
nodes_up 2
for n in $(nodes_names); do
	in_node "$n" 'useradd -m devops && printf "devops ALL=(ALL) NOPASSWD: ALL\n" >/etc/sudoers.d/devops && chmod 440 /etc/sudoers.d/devops && install -d -m 700 -o devops -g devops /home/devops/.ssh'
	in_node -i "$n" 'cat >/home/devops/.ssh/authorized_keys && chown devops: /home/devops/.ssh/authorized_keys && chmod 600 /home/devops/.ssh/authorized_keys' </home/greg/.ssh/id_ed25519.pub
done
