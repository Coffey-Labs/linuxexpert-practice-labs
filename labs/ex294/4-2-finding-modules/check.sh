nodes_wait 60 || true
# ans CMD: run CMD as greg in his project directory.
ans() { timeout 300 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
OUT=$LAB_STATE/check.out

task 1 "The module that manages SELinux booleans"
need "/root/lab-answers/1 names it in full" '[ "$(answer 1)" = ansible.posix.seboolean ]'

task 2 "A community.general.lvg task makes volume group data on /dev/loop41"
need "a playbook in /home/greg/ansible uses community.general.lvg" 'grep -lsq "community\.general\.lvg" /home/greg/ansible/*.yml /home/greg/ansible/*.yaml'
need "volume group data exists" 'vgs data'
need "data's physical volume is /dev/loop41" 'pvs --noheadings -o pv_name,vg_name | grep -Eq "^ */dev/loop41 +data *$"'

task 3 "both.yml: a module only the image has"
B=/home/greg/ansible/both.yml
need "$B exists" '[ -f "$B" ]'
need "ansible-navigator run both.yml --syntax-check passes" 'ans ansible-navigator run both.yml --syntax-check -m stdout'
need "ansible-playbook both.yml --syntax-check fails with couldn't resolve module/action" 'ans ansible-playbook both.yml --syntax-check >"$OUT" 2>&1; grep -q "couldn.t resolve module/action" "$OUT"'
rm -f "$OUT"
