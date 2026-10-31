# The control node: ansible-core, git and greg's project, with his key.
for p in ansible-core git-core; do pkg_installed $p || echo $p >>"$LAB_STATE/missing"; done
pkg_installed ansible-core || pkg_install ansible-core
pkg_installed git-core || pkg_install git-core
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
cat >/home/greg/ansible/site.yml <<'C'
---
- name: A web server
  hosts: node1
  become: true
  tasks:
    - name: Install httpd
      ansible.builtin.dnf:
        name: httpd
        state: present

    - name: Start and enable httpd
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: true
C
chown greg: /home/greg/ansible/ansible.cfg /home/greg/ansible/inventory /home/greg/ansible/site.yml

# The managed nodes: devops with greg's key and sudo, and git.
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
		rm -rf /srv/git' </home/greg/.ssh/id_ed25519.pub
	say "${C_DIM}Installing git on $n...${C_0}"
	in_node "$n" 'rpm -q git-core >/dev/null || dnf -y -q install git-core >/dev/null'
done

# The repository on node1 with one commit, and greg's clone of it.
in_node node1 'install -d -o devops -g devops /srv/git/playbooks.git &&
	runuser -u devops -- git init -q --bare -b main /srv/git/playbooks.git'
runuser -l greg -c 'ssh-keyscan -t ed25519 node1 2>/dev/null >>~/.ssh/known_hosts
	git config --global user.name "Greg"
	git config --global user.email greg@lab.example.com
	git -c init.defaultBranch=main clone -q devops@node1:/srv/git/playbooks.git 2>/dev/null
	cd playbooks && printf "# Playbooks\n\nAnsible work for the lab nodes.\n" >README.md &&
	git add README.md && git commit -q -m "Start the repository" && git push -q -u origin main' </dev/null
[ "$(in_node node1 git --git-dir=/srv/git/playbooks.git rev-list --count main)" = 1 ] ||
	die "could not make the repository on node1"
