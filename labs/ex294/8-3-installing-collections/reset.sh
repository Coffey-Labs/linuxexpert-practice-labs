# The node goes with nodes_down and greg (with his project) with
# users_remove (his collections too); here what setup installed.
while read -r p; do dnf -y -q remove "$p" >/dev/null 2>&1; done <"$LAB_STATE/missing" 2>/dev/null
true
