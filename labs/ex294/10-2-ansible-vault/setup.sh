# The control node: ansible-core, ansible-navigator (in its own Python
# environment) and greg's project, with his key.
for p in ansible-core; do pkg_installed $p || echo $p >>"$LAB_STATE/missing"; done
pkg_installed ansible-core || pkg_install ansible-core
if ! command -v ansible-navigator >/dev/null; then
	say "${C_DIM}Installing ansible-navigator...${C_0}"
	state_set navigator /opt/le-lab-navigator
	python3 -m venv /opt/le-lab-navigator
	/opt/le-lab-navigator/bin/pip install -q --disable-pip-version-check ansible-navigator >/dev/null ||
		die "could not install ansible-navigator from PyPI"
	ln -sf /opt/le-lab-navigator/bin/ansible-navigator /usr/local/bin/ansible-navigator
fi
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
printf '[nodes]\nnode1\n' >/home/greg/ansible/inventory
cat >/home/greg/ansible/ansible-navigator.yml <<'C'
---
ansible-navigator:
  execution-environment:
    enabled: false
C
chown greg: /home/greg/ansible/ansible.cfg /home/greg/ansible/inventory /home/greg/ansible/ansible-navigator.yml

# The managed node: devops with greg's key and sudo, and no vaultuser.
nodes_up 1
in_node -i node1 'id devops >/dev/null 2>&1 || useradd -m devops
	echo devops:Lab-Pass-1 | chpasswd
	echo "devops ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/devops
	chmod 440 /etc/sudoers.d/devops
	install -d -m 700 -o devops -g devops /home/devops/.ssh
	cat >/home/devops/.ssh/authorized_keys
	chown devops: /home/devops/.ssh/authorized_keys
	chmod 600 /home/devops/.ssh/authorized_keys
	userdel -r vaultuser 2>/dev/null; true' </home/greg/.ssh/id_ed25519.pub
