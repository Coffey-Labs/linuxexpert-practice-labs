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
cat >/home/greg/ansible/user_list.yml <<'X'
---
users:
  - name: fred
    job: developer
    uid: 3001
  - name: wilma
    job: manager
    uid: 3002
  - name: barney
    job: developer
    uid: 3003
X
chown greg: /home/greg/ansible/ansible.cfg /home/greg/ansible/inventory /home/greg/ansible/user_list.yml

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
