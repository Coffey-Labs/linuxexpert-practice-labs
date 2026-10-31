# The node goes with nodes_down and greg (with his project) with
# users_remove; ansible-navigator and the packages the lab installed here.
if [ "$(state_get navigator)" = /opt/le-lab-navigator ]; then
	rm -f /usr/local/bin/ansible-navigator
	rm -rf /opt/le-lab-navigator
fi
while read -r p; do dnf -y -q remove "$p" >/dev/null 2>&1; done <"$LAB_STATE/missing" 2>/dev/null
true
