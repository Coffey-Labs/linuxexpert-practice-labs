nodes_wait 60 || true
# ans CMD: run CMD as greg in his project directory.
ans() { timeout 300 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
OUT=$LAB_STATE/check.out Q="'"
for n in $(nodes_names); do in_node "$n" cat /var/log/lab-runs.log 2>/dev/null; done >"$OUT.runs"
N=$(state_get note)

task 1 "site.yml run with ansible-playbook, and with navigator limited to one node"
need "a node logged a run of site.yml by ansible-playbook" 'grep -q " ansible-playbook in the control node, " "$OUT.runs"'
need "a node logged a run of site.yml by ansible-navigator in the execution environment, with --limit" 'grep " ansible-navigator in an execution environment, limit " "$OUT.runs" | grep -vq "limit none$"'

task 2 "Open a task's result in navigator's interactive mode" self

task 3 "note.yml prints the note with a file lookup, with both commands"
P=/home/greg/ansible/note.yml
need "$P exists" '[ -f "$P" ]'
need "note.yml uses a file lookup" 'grep -Eq "(lookup|query|q)\( *[\"$Q](ansible\.builtin\.)?file[\"$Q]" "$P"'
need "a copy of the note is in /home/greg/ansible" 'grep -rlqF "$N" /home/greg/ansible --exclude="*.log" --exclude="*.json"'
need "ansible-playbook note.yml prints the note" 'ans ansible-playbook note.yml | grep -qF "$N"'
need "ansible-navigator run note.yml -m stdout prints the note" 'ans ansible-navigator run note.yml -m stdout | grep -qF "$N"'
rm -f "$OUT" "$OUT.runs"
