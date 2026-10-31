# Navigator, if the lab installed it. greg (with his project and his
# podman images) goes with users_remove, the nodes with nodes_down.
if [ "$(state_get navigator)" = installed ]; then
	rm -f /usr/local/bin/ansible-navigator
	rm -rf /opt/le-lab-navigator
fi
if id greg >/dev/null 2>&1; then
	runuser -l greg -c 'podman system reset -f' >/dev/null 2>&1
fi
while read -r p; do dnf -y -q remove "$p" >/dev/null 2>&1; done <"$LAB_STATE/missing" 2>/dev/null
# devops and the spare disk go with users_remove and disks_remove.
rm -f /etc/sudoers.d/le-lab-devops
true
