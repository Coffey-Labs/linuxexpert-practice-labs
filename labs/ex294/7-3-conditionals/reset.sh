# The nodes go with nodes_down and greg (with his project) with
# users_remove; here the hardware unit and what setup installed.
if [ -f /etc/systemd/system/le-lab-node-hw.service ]; then
	systemctl disable --quiet --now le-lab-node-hw.service 2>/dev/null
	rm -f /etc/systemd/system/le-lab-node-hw.service
	systemctl daemon-reload
fi
while read -r p; do dnf -y -q remove "$p" >/dev/null 2>&1; done <"$LAB_STATE/missing" 2>/dev/null
true
