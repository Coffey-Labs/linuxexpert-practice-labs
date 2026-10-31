# Time and SELinux can't be managed in a container node (they belong to
# the VM's kernel), so this lab manages the control node itself.
command -v getenforce >/dev/null && [ "$(getenforce)" != Disabled ] ||
	refuse "SELinux is disabled on this VM; turning it on needs a relabel and a reboot"
[ -f /etc/chrony.conf ] || refuse "/etc/chrony.conf is missing; install chrony first"

# Everything installed from here on (by setup or by the roles) goes again
# at reset.
rpm -qa --qf '%{NAME}\n' | sort -u >"$LAB_STATE/rpms"
for p in ansible-core rhel-system-roles; do pkg_installed $p || pkg_install $p; done

# What the tasks change, as it was.
cp -a /etc/chrony.conf "$LAB_STATE/chrony.conf"
cp -a /etc/selinux/config "$LAB_STATE/selinux-config"
state_set enforce "$(getenforce)"
state_set boolean "$(getsebool httpd_can_network_connect | awk '{print $3}')"

# The starting point: SELinux permissive, the boolean off.
sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
setenforce 0
setsebool -P httpd_can_network_connect off

# greg's project; he may use sudo, for become on localhost.
user_add greg
printf 'greg ALL=(ALL) NOPASSWD: ALL\n' >/etc/sudoers.d/le-lab-greg
chmod 440 /etc/sudoers.d/le-lab-greg
install -d -m 755 -o greg -g greg /home/greg/ansible
cat >/home/greg/ansible/ansible.cfg <<'X'
[defaults]
inventory = inventory

[privilege_escalation]
become = true
X
printf '[webservers]\nlocalhost ansible_connection=local\n' >/home/greg/ansible/inventory
chown greg: /home/greg/ansible/ansible.cfg /home/greg/ansible/inventory
