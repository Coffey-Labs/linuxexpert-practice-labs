# The mount points the tasks use must be free.
for m in /srv/archive /mnt/data /srv/web; do
	if findmnt -n "$m" >/dev/null || awk -v m="$m" '$1 !~ /^#/ && $2 == m' /etc/fstab | grep -q .; then
		refuse "$m is already mounted or in /etc/fstab; free it first"
	fi
done
vgs research >/dev/null 2>&1 && refuse "a volume group called research already exists"
vgs vg_web >/dev/null 2>&1 && refuse "a volume group called vg_web already exists"

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
[storage]
localhost ansible_connection=local

[nodes]
node1
X
chown greg: /home/greg/ansible/ansible.cfg /home/greg/ansible/inventory

# One managed node, prepared as in chapter 3.1 (devops with greg's key and
# passwordless sudo), with the LVM tools but no disks: a host without the
# volume group (task 2).
nodes_up 1
in_node -i node1 'useradd -m devops && install -d -m 700 -o devops -g devops /home/devops/.ssh &&
	cat >/home/devops/.ssh/authorized_keys && chown devops: /home/devops/.ssh/authorized_keys &&
	chmod 600 /home/devops/.ssh/authorized_keys &&
	echo "devops ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/devops && chmod 440 /etc/sudoers.d/devops' \
	</home/greg/.ssh/id_ed25519.pub
in_node node1 dnf -y -q install lvm2 >/dev/null
# What's installed here now; reset removes what the tasks add.
rpm -qa --qf '%{NAME}\n' | sort -u >"$LAB_STATE/rpms"

# The control node's spare disks.
disk_add 0 2G >/dev/null
disk_add 1 1G >/dev/null
disk_add 2 2G >/dev/null
