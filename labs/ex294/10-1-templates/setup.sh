# The control node: ansible-core, and greg with an SSH key and his project.
pkg_installed ansible-core || { echo ansible-core >>"$LAB_STATE/missing"; pkg_install ansible-core; }
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
printf '[webservers]\nnode1\nnode2\n\n[dbservers]\nnode3\n' >/home/greg/ansible/inventory
chown greg: /home/greg/ansible/ansible.cfg /home/greg/ansible/inventory

# The managed nodes, each with devops: greg's key and passwordless sudo.
nodes_up 3
for n in $(nodes_names); do
	in_node $n 'useradd -m devops && echo "devops ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/devops && chmod 440 /etc/sudoers.d/devops && install -d -m 700 -o devops -g devops /home/devops/.ssh'
	in_node -i $n 'install -m 600 -o devops -g devops /dev/stdin /home/devops/.ssh/authorized_keys' </home/greg/.ssh/id_ed25519.pub
done

# Nodes share the VM's memory and disks. So that facts differ by host, each
# node gets its own /proc/meminfo and /sys/block (bind mounts made from the
# VM into the node), again at every boot by le-lab-node-hw.service.
# NAME MEMORY-MiB DISK:GiB...
cat >"$LAB_STATE/hardware" <<'X'
node1 4096 vda:20 vdb:2 vdd:1
node2 2048 vda:20 vdb:2
node3 1024 vda:20
X
cat >"$LAB_STATE/hardware.sh" <<'X'
#!/bin/bash
cd "$(dirname "$0")" || exit 1
while read -r name mem disks; do
	pid=$(podman inspect -f '{{.State.Pid}}' "$name" 2>/dev/null)
	[ "${pid:-0}" -gt 0 ] || continue
	for m in /proc/meminfo /sys/block; do
		nsenter -t "$pid" -m findmnt -n --mountpoint "$m" >/dev/null && nsenter -t "$pid" -m umount "$m"
	done
	podman exec -i "$name" bash -s -- "$mem" $disks <<'Y'
d=/var/lib/le-lab-hw mem=$1; shift
rm -rf $d; mkdir -p $d/block
awk -v kb=$((mem * 1024)) '
	/^MemTotal:/ { printf "MemTotal:       %8d kB\n", kb; next }
	/^(MemFree|MemAvailable):/ { printf "%-16s%8d kB\n", $1, kb / 2; next }
	{ print }' /proc/meminfo >$d/meminfo
for x; do
	b=$d/block/${x%%:*}
	mkdir -p $b/device $b/queue
	echo $((${x#*:} * 2097152)) >$b/size
	echo 0 >$b/removable; echo 1 >$b/queue/rotational
	echo 512 >$b/queue/logical_block_size; echo 512 >$b/queue/physical_block_size
	echo "Virtual disk" >$b/device/model
done
Y
	nsenter -t "$pid" -m mount --bind /var/lib/le-lab-hw/meminfo /proc/meminfo
	nsenter -t "$pid" -m mount --bind /var/lib/le-lab-hw/block /sys/block
done <hardware
X
cat >/etc/systemd/system/le-lab-node-hw.service <<X
[Unit]
Description=LINUXexpert practice lab: each node's memory and disks
After=le-lab-nodes.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash $LAB_STATE/hardware.sh

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --quiet --now le-lab-node-hw.service

# Ready to go: greg reaches every node as root.
timeout 120 runuser -l greg -c 'cd ~/ansible && ansible all -o -a id' </dev/null | grep -c 'uid=0(root)' | grep -qx 3
