# The control node: ansible-core, python3-pip (for ansible-navigator's
# virtual environment) and greg with a key and quiet rootless podman.
for p in ansible-core python3-pip; do
	pkg_installed $p || { echo $p >>"$LAB_STATE/missing"; pkg_install $p; }
done
user_add greg
install -d -m 700 -o greg -g greg /home/greg/.ssh
runuser -u greg -- ssh-keygen -q -t ed25519 -N '' -f /home/greg/.ssh/id_ed25519
# Without a systemd user session (su, sudo -i), podman would warn on every
# run; the cgroupfs manager works the same in any login.
install -d -m 755 -o greg -g greg /home/greg/.config /home/greg/.config/containers
printf '[engine]\ncgroup_manager = "cgroupfs"\nevents_logger = "file"\n' >/home/greg/.config/containers/containers.conf
chown greg: /home/greg/.config/containers/containers.conf

# greg's project. ansible-navigator.yml also names another inventory
# (task 1) and another ansible.cfg (task 2); the role lives outside the
# project (task 3).
install -d -m 755 -o greg -g greg /home/greg/ansible /home/greg/ansible/old
cat >/home/greg/ansible/ansible.cfg <<'X'
[defaults]
inventory = ./inventory
remote_user = devops
host_key_checking = false

[privilege_escalation]
become = true
X
printf '[webservers]\nnode1\n\n[dbservers]\nnode2\n' >/home/greg/ansible/inventory
printf '[web]\nnode1\nnode2\n' >/home/greg/ansible/old/inventory
cat >/home/greg/ansible/old/ansible.cfg <<'X'
[defaults]
inventory = ./inventory
remote_user = devops
host_key_checking = false
forks = 2

[privilege_escalation]
become = true
X
cat >/home/greg/ansible/ansible-navigator.yml <<'X'
---
ansible-navigator:
  ansible:
    config:
      path: ./old/ansible.cfg
    inventory:
      entries:
        - ./old/inventory
  execution-environment:
    image: localhost/lab-ee:2.16
    pull:
      policy: never
  mode: stdout
  playbook-artifact:
    enable: false
X
cat >/home/greg/ansible/banner.yml <<'X'
---
- name: Put up the banner
  hosts: all
  roles:
    - banner
X
install -d -m 755 -o greg -g greg /home/greg/roles /home/greg/roles/banner /home/greg/roles/banner/tasks
cat >/home/greg/roles/banner/tasks/main.yml <<'X'
---
- name: Write the banner
  ansible.builtin.copy:
    content: "This node is managed by Ansible.\n"
    dest: /etc/motd.d/banner
    mode: "0644"
X
chown -R greg: /home/greg/ansible /home/greg/roles

# The managed nodes, with devops: greg's key and passwordless sudo.
nodes_up 2
for n in $(nodes_names); do
	in_node "$n" 'useradd -m devops && printf "devops ALL=(ALL) NOPASSWD: ALL\n" >/etc/sudoers.d/devops && chmod 440 /etc/sudoers.d/devops && install -d -m 700 -o devops -g devops /home/devops/.ssh'
	in_node -i "$n" 'cat >/home/devops/.ssh/authorized_keys && chown devops: /home/devops/.ssh/authorized_keys && chmod 600 /home/devops/.ssh/authorized_keys' </home/greg/.ssh/id_ed25519.pub
done

# ansible-navigator from PyPI, in its own virtual environment. Only the
# command goes on the PATH, so ansible-playbook stays the RPM's (and
# --ee false runs the control node's ansible-core).
if [ ! -e /usr/local/bin/ansible-navigator ]; then
	say "${C_DIM}Installing ansible-navigator...${C_0}"
	python3 -m venv /opt/le-lab-navigator
	for i in 1 2 3; do
		/opt/le-lab-navigator/bin/pip install -q --disable-pip-version-check 'ansible-navigator==26.10.0' >/dev/null && break
		sleep 5
	done
	ln -s /opt/le-lab-navigator/bin/ansible-navigator /usr/local/bin/ansible-navigator
	/usr/local/bin/ansible-navigator --version >/dev/null
	state_set navigator installed
fi

# The execution environment localhost/lab-ee:2.16: the node image with
# ansible-core and ansible.posix and community.general from Ansible Galaxy.
# Built as root, given to greg's rootless podman, and removed from root's.
say "${C_DIM}Building the execution environment image...${C_0}"
d=$(mktemp -d)
cat >"$d/Containerfile" <<X
FROM $LE_NODE_IMAGE
LABEL ansible-execution-environment=true
RUN dnf -y -q --setopt=install_weak_deps=False install ansible-core \\
    && for i in 1 2 3; do \\
        ansible-galaxy collection install -p /usr/share/ansible/collections \\
            'ansible.posix:>=2,<3' 'community.general:>=11,<12' && break; sleep 5; \\
    done \\
    && ansible-doc community.general.lvg >/dev/null && ansible-doc ansible.posix.seboolean >/dev/null \\
    && dnf clean all
X
podman build -q --layers=false -t localhost/lab-ee:2.16 "$d" >/dev/null
rm -rf "$d"
podman save localhost/lab-ee:2.16 | runuser -l greg -c 'podman load -q' >/dev/null 2>&1
podman rmi localhost/lab-ee:2.16 >/dev/null
runuser -l greg -c 'podman image exists localhost/lab-ee:2.16'
