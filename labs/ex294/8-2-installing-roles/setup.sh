[ -e /srv/git ] && refuse "/srv/git already exists; the lab keeps its Git repository there"
# The control node: ansible-core, and greg with an SSH key and his project.
for p in ansible-core git; do pkg_installed $p || { echo $p >>"$LAB_STATE/missing"; pkg_install $p; }; done
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
printf '[nodes]\nnode1\n' >/home/greg/ansible/inventory
chown greg: /home/greg/ansible/ansible.cfg /home/greg/ansible/inventory

# The managed nodes, each with devops: greg's key and passwordless sudo.
nodes_up 1
for n in $(nodes_names); do
	in_node $n 'useradd -m devops && echo "devops ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/devops && chmod 440 /etc/sudoers.d/devops && install -d -m 700 -o devops -g devops /home/devops/.ssh'
	in_node -i $n 'install -m 600 -o devops -g devops /dev/stdin /home/devops/.ssh/authorized_keys' </home/greg/.ssh/id_ed25519.pub
done

# node1 runs a web server, for the role tarballs.
in_node node1 'dnf -y -q install httpd >/dev/null && systemctl enable --now --quiet httpd'

# Two roles to package, in greg's ~/role-src.
G="runuser -u greg --"
$G mkdir /home/greg/role-src
for r in motd issue; do
	(cd /home/greg/role-src && $G ansible-galaxy role init $r >/dev/null)
done
cat >/home/greg/role-src/motd/tasks/main.yml <<'X'
---
- name: Write the message of the day
  ansible.builtin.copy:
    content: "{{ motd_text }}\n"
    dest: /etc/motd
    mode: "0644"
X
printf -- '---\nmotd_text: Managed by Ansible\n' >/home/greg/role-src/motd/defaults/main.yml
cat >/home/greg/role-src/issue/tasks/main.yml <<'X'
---
- name: Write the login banner
  ansible.builtin.copy:
    content: "{{ issue_text }}\n"
    dest: /etc/issue.net
    mode: "0644"
X
printf -- '---\nissue_text: Authorized users only\n' >/home/greg/role-src/issue/defaults/main.yml
chown -R greg: /home/greg/role-src

# A third role in a Git repository, with the branches main and devel.
state_set made-srv-git yes
install -d -m 755 -o greg -g greg /srv/git
W=$(runuser -u greg -- mktemp -d)
(
	cd "$W"
	$G ansible-galaxy role init chrony >/dev/null
	cat >chrony/tasks/main.yml <<'X'
---
- name: Install chrony
  ansible.builtin.dnf:
    name: chrony
    state: present
X
	chown -R greg: chrony
	cd chrony
	C="git -c user.name=Lab -c user.email=lab@lab.example"
	$G git init -q -b main
	$G git add .
	$G $C commit -q -m "The chrony role"
	$G git checkout -q -b devel
	printf -- '---\nchrony_pool: 2.pool.ntp.org\n' >defaults/main.yml
	$G $C commit -q -a -m "A default pool"
	$G git clone -q --bare . /srv/git/chrony-role.git
)
rm -rf "$W"
state_set devel "$(runuser -u greg -- git --git-dir=/srv/git/chrony-role.git rev-parse devel)"

# Ready to go: greg reaches node1 as root.
timeout 120 runuser -l greg -c 'cd ~/ansible && ansible all -o -a id' </dev/null | grep -q 'uid=0(root)'
