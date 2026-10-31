# The control node: ansible-core and greg's project, with his key.
for p in ansible-core; do pkg_installed $p || echo $p >>"$LAB_STATE/missing"; done
pkg_installed ansible-core || pkg_install ansible-core
user_add greg
install -d -m 700 -o greg -g greg /home/greg/.ssh
runuser -u greg -- ssh-keygen -q -t ed25519 -N '' -f /home/greg/.ssh/id_ed25519
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

# The managed nodes: devops with greg's key and sudo, no httpd and no
# swap file; firewalld running on node1, with only SSH open.
nodes_up 2
for n in $(nodes_names); do
	in_node -i "$n" 'id devops >/dev/null 2>&1 || useradd -m devops
		echo devops:Lab-Pass-1 | chpasswd
		echo "devops ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/devops
		chmod 440 /etc/sudoers.d/devops
		install -d -m 700 -o devops -g devops /home/devops/.ssh
		cat >/home/devops/.ssh/authorized_keys
		chown devops: /home/devops/.ssh/authorized_keys
		chmod 600 /home/devops/.ssh/authorized_keys
		rm -f /root/swapfile' </home/greg/.ssh/id_ed25519.pub
done
say "${C_DIM}Installing firewalld on node1...${C_0}"
in_node node1 'rpm -q firewalld >/dev/null || dnf -y -q install firewalld >/dev/null
	systemctl enable --now firewalld >/dev/null 2>&1
	for i in $(seq 30); do firewall-cmd -q --state 2>/dev/null && break; sleep 1; done
	for s in $(firewall-cmd --permanent --list-services); do
		[ "$s" = ssh ] || firewall-cmd -q --permanent --remove-service="$s"
	done
	firewall-cmd -q --reload'
in_node node1 'firewall-cmd --state' >/dev/null || die "firewalld didn't start on node1"
