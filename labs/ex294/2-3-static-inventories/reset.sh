# The nodes go with nodes_down and greg (with his project) with
# users_remove; ansible-core goes if the lab installed it.
while read -r p; do dnf -y -q remove "$p" >/dev/null 2>&1; done <"$LAB_STATE/missing" 2>/dev/null
true
