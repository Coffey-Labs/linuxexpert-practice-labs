# The nodes go with nodes_down, greg (with his project and key) with
# users_remove, and /root/lab-answers with le-lab; ansible-core if setup
# installed it.
while read -r p; do dnf -y -q remove "$p" >/dev/null 2>&1; done <"$LAB_STATE/missing" 2>/dev/null
# The collection task 1 installs: greg's copy (it goes with greg too) and a
# system-wide one setup didn't find.
rm -rf /home/greg/.ansible/collections
while read -r d; do rm -rf "$d"; done <"$LAB_STATE/new-dirs" 2>/dev/null
true
