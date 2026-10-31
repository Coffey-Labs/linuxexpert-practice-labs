# The web server is this VM, with SELinux enforcing and no Apache yet.
[ "$(getenforce 2>/dev/null)" = Enforcing ] || refuse "SELinux must be enforcing (getenforce); set it back first"
pkg_installed httpd && refuse "Apache (httpd) is already installed; this lab installs it from scratch, so use a VM without it"
[ -e /srv/www ] && refuse "/srv/www already exists; move it away first"
listening 80 tcp && refuse "something already listens on port 80"
listening 8888 tcp && refuse "something already listens on port 8888"

# The control node: ansible-core, semanage for checking, and greg's
# project, with sudo without a password for the localhost plays.
for p in ansible-core policycoreutils-python-utils; do
	pkg_installed $p || { echo $p >>"$LAB_STATE/missing"; pkg_install $p; }
done
if semanage fcontext -l -C | grep -q '^/srv/www'; then refuse "there's already a file context rule for /srv/www (semanage fcontext -l -C)"; fi
if semanage port -l -C | grep -Eq '[ ,]8888(,|$)'; then refuse "port 8888 already has a local SELinux label (semanage port -l -C)"; fi
user_add greg
printf 'greg ALL=(ALL) NOPASSWD: ALL\n' >/etc/sudoers.d/le-lab-greg
chmod 440 /etc/sudoers.d/le-lab-greg
install -d -m 755 -o greg -g greg /home/greg/ansible
cat >/home/greg/ansible/ansible.cfg <<'X'
[defaults]
inventory = inventory
host_key_checking = false

[privilege_escalation]
become = true
X
printf '[webservers]\nlocalhost ansible_connection=local\n' >/home/greg/ansible/inventory
chown greg: /home/greg/ansible/ansible.cfg /home/greg/ansible/inventory
# What's installed here now; reset removes what the tasks add.
rpm -qa --qf '%{NAME}\n' | sort -u >"$LAB_STATE/rpms"

# Task 2 starts off.
state_set boolean "$(getsebool httpd_can_network_connect | awk '{print $NF}')"
setsebool -P httpd_can_network_connect off
# The firewall, as it is, for reset.
if active firewalld; then
	touch "$LAB_STATE/firewalld"
	firewall-cmd -q --permanent --query-service=http && touch "$LAB_STATE/had-http"
	firewall-cmd -q --permanent --query-port=8888/tcp && touch "$LAB_STATE/had-8888"
fi
true
