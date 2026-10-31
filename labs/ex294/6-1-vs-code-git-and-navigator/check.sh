nodes_wait 60 || true
OUT=$LAB_STATE/check.out
R=/home/greg/git/ansible.git B=$(state_get base)
# gg ARGS: git as greg in the repository.
gg() { runuser -u greg -- git -C "$R" "$@" </dev/null; }
for n in $(nodes_names); do in_node "$n" cat /var/log/lab-runs.log 2>/dev/null | sed "s/^/$n /"; done >"$OUT.runs"

task 1 "A new playbook committed and pushed to main"
need "main has a commit after the lab's first one" '[ "$(gg rev-parse main)" != "$B" ] && gg merge-base --is-ancestor "$B" main'
gg diff --name-only --diff-filter=A "$B" main 2>/dev/null | grep -E '\.ya?ml$' >"$OUT.new"
need "the new commits add a .yml or .yaml file" 'grep -q . "$OUT.new"'
need "a fresh clone has a new file that is a playbook (ansible-playbook --syntax-check)" 'C=$(runuser -u greg -- mktemp -d) && runuser -u greg -- git clone -q "$R" "$C/p" && ok=1; while read -r f; do timeout 60 runuser -l greg -c "cd $C/p && ansible-playbook --syntax-check $f" </dev/null && grep -q "hosts:" "$C/p/$f" && { ok=0; break; }; done <"$OUT.new"; rm -rf "$C"; exit $ok'

task 2 "A playbook run in the execution environment from the menu" self

task 3 "site.yml via ansible-playbook with --limit node1"
need "node1 logged a run of site.yml by ansible-playbook with limit node1" 'grep -q "^node1 .* ansible-playbook, limit node1$" "$OUT.runs"'
rm -f "$OUT".*
