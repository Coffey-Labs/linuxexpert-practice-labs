# The nodes (with httpd and firewalld) go with nodes_down, and greg (with
# his project and collections) with users_remove; the packages the lab
# installed here.
while read -r p; do dnf -y -q remove "$p" >/dev/null 2>&1; done <"$LAB_STATE/missing" 2>/dev/null
true
