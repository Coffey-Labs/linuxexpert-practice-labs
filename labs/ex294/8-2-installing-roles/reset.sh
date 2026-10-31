# The node goes with nodes_down and greg (with his project and role
# sources) with users_remove; here the Git repository and what setup
# installed.
[ -f "$LAB_STATE/made-srv-git" ] && rm -rf /srv/git
while read -r p; do dnf -y -q remove "$p" >/dev/null 2>&1; done <"$LAB_STATE/missing" 2>/dev/null
true
