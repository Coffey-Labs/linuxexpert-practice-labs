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

# node1 gets a package one version behind (task 3).
old=''
for p in tar sudo 'openssh openssh-server openssh-clients'; do
	if in_node node1 "dnf -y -q downgrade $p" >/dev/null 2>&1; then old=${p%% *}; break; fi
done
[ -n "$old" ] || die "could not put an older package on node1; run le-lab reset and try again"
state_set old-pkg "$old"
state_set old-ver "$(in_node node1 rpm -q "$old")"

# Neither node has any repositories (task 1). gnupg2 first, which a full
# system has and rpm_key needs.
for n in $(nodes_names); do
	in_node "$n" 'dnf -y -q install gnupg2 && mkdir -p /root/repos.orig && mv /etc/yum.repos.d/*.repo /root/repos.orig/ && dnf -q clean all' >/dev/null
done
