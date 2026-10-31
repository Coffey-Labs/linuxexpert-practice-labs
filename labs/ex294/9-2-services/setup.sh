# The control node: ansible-core and greg's project, with a key the nodes
# already accept, and sudo without a password for the localhost plays.
pkg_installed ansible-core || { echo ansible-core >>"$LAB_STATE/missing"; pkg_install ansible-core; }
user_add greg
printf 'greg ALL=(ALL) NOPASSWD: ALL\n' >/etc/sudoers.d/le-lab-greg
chmod 440 /etc/sudoers.d/le-lab-greg
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
cat >/home/greg/ansible/inventory <<'X'
[webservers]
node1

[dbservers]
node2

[control]
localhost ansible_connection=local
X
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

# This VM's own settings the tasks may change, for reset.
for u in chronyd rpcbind rpcbind.socket; do
	state_set "unit-$u" "$(systemctl is-enabled "$u" 2>/dev/null) $(systemctl is-active "$u" 2>/dev/null)"
done
state_set default-target "$(systemctl get-default)"
[ -e /etc/systemd/system/hello.service ] && touch "$LAB_STATE/had-hello"

# Task 1: chronyd stopped here, rpcbind running on the nodes.
systemctl disable --now --quiet chronyd 2>/dev/null || true
for n in $(nodes_names); do
	in_node "$n" 'dnf -y -q install rpcbind && systemctl enable --now --quiet rpcbind' >/dev/null
done
# Task 3: node2 boots to graphical.target.
in_node node2 systemctl set-default graphical.target >/dev/null 2>&1
