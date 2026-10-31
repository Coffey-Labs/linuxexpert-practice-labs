# The control node: ansible-core, npm (task 3 installs the devcontainer CLI
# with it), and greg with a key and quiet rootless podman.
for p in ansible-core nodejs-npm; do
	pkg_installed $p || { echo $p >>"$LAB_STATE/missing"; pkg_install $p; }
done
[ -e /usr/local/bin/devcontainer ] && state_set devcontainer-cli present
user_add greg
install -d -m 700 -o greg -g greg /home/greg/.ssh
runuser -u greg -- ssh-keygen -q -t ed25519 -N '' -f /home/greg/.ssh/id_ed25519
# Without a systemd user session (su, sudo -i), podman would warn on every
# run; the cgroupfs manager works the same in any login.
install -d -m 755 -o greg -g greg /home/greg/.config /home/greg/.config/containers
printf '[engine]\ncgroup_manager = "cgroupfs"\nevents_logger = "file"\n' >/home/greg/.config/containers/containers.conf
chown greg: /home/greg/.config/containers/containers.conf

# greg's project, with no .devcontainer yet (task 1). site.yml records
# each run on the node (tasks 2 and 3).
install -d -m 755 -o greg -g greg /home/greg/ansible
cat >/home/greg/ansible/ansible.cfg <<'X'
[defaults]
inventory = ./inventory
remote_user = devops
host_key_checking = false

[privilege_escalation]
become = true
X
printf '[nodes]\nnode1\nnode2\n' >/home/greg/ansible/inventory
cat >/home/greg/ansible/site.yml <<'X'
---
- name: Check the managed nodes
  hosts: all
  vars:
    run_from: "{{ 'VS Code' if lookup('ansible.builtin.env', 'TERM_PROGRAM') == 'vscode' else 'a shell' }}"
  tasks:
    - name: Make sure the node answers
      ansible.builtin.ping:

    - name: Record this run in /var/log/lab-runs.log
      ansible.builtin.lineinfile:
        path: /var/log/lab-runs.log
        line: "{{ now(utc=true, fmt='%Y-%m-%d %H:%M:%S') }} {{ playbook_dir }} ansible-core {{ ansible_version.full }} from {{ run_from }}"
        create: true
        mode: "0644"
      changed_when: false
X
chown greg: /home/greg/ansible/*

# The managed nodes, with devops: greg's key and passwordless sudo.
nodes_up 2
for n in $(nodes_names); do
	in_node "$n" 'useradd -m devops && printf "devops ALL=(ALL) NOPASSWD: ALL\n" >/etc/sudoers.d/devops && chmod 440 /etc/sudoers.d/devops && install -d -m 700 -o devops -g devops /home/devops/.ssh'
	in_node -i "$n" 'cat >/home/devops/.ssh/authorized_keys && chown devops: /home/devops/.ssh/authorized_keys && chmod 600 /home/devops/.ssh/authorized_keys' </home/greg/.ssh/id_ed25519.pub
done

# The development container image, in greg's podman (about 1.4 GB).
say "${C_DIM}Pulling the development container image...${C_0}"
for i in 1 2 3; do
	runuser -l greg -c 'podman pull -q ghcr.io/ansible/community-ansible-dev-tools:latest' >/dev/null 2>&1 && break
	sleep 5
done
runuser -l greg -c 'podman image exists ghcr.io/ansible/community-ansible-dev-tools:latest'
