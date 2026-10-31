# The nodes go with nodes_down, greg (with his project and key) with
# users_remove, and /root/lab-answers with le-lab; ansible-core if setup
# installed it.
while read -r p; do dnf -y -q remove "$p" >/dev/null 2>&1; done <"$LAB_STATE/missing" 2>/dev/null
true
