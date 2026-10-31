nodes_wait 60 || true
R=/srv/git/playbooks.git
C=/home/greg/playbooks
# g CMD: run git CMD as greg, over SSH with his key and no prompts.
g() {
	setsid -w timeout 60 runuser -u greg -- env HOME=/home/greg \
		GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10" \
		git "$@" </dev/null
}
# rg CMD: git CMD in node1's repository.
rg() { in_node node1 git --git-dir=$R "$@"; }
# The other clones of it in greg's home.
others() {
	find /home/greg -maxdepth 3 -name .git -type d 2>/dev/null | while read -r d; do
		d=${d%/.git}; [ "$d" = "$C" ] && continue
		g -C "$d" remote get-url origin 2>/dev/null |
			grep -Eq '^(ssh://)?([^@/]+@)?(node1(\.lab\.example)?|10\.99\.1\.11)(:[0-9]+)?[:/]+srv/git/playbooks\.git/?$' &&
			printf '%s\n' "$d"
	done
}
ignored() { g -C $C check-ignore -q --no-index "$1"; }

task 1 "site.yml committed and pushed"
need "main in node1's repository has site.yml" "rg ls-tree -r --name-only main | grep -qx site.yml"
need "it's the playbook from /home/greg/ansible" "rg show main:site.yml | grep -q 'name: A web server'"

task 2 "A committed .gitignore for artifacts, navigator logs and .vault_pass"
need "$C/.gitignore is committed, with no changes since" "g -C $C ls-files --error-unmatch .gitignore && g -C $C diff --quiet HEAD -- .gitignore"
need "it ignores navigator artifacts such as site-artifact-2026-10-30T10:00:00.json" "ignored site-artifact-2026-10-30T10:00:00.json"
need "it ignores ansible-navigator.log" "ignored ansible-navigator.log"
need "it ignores .vault_pass" "ignored .vault_pass"
need "it doesn't ignore playbooks" "! ignored site.yml"

task 3 "A rejected push, a pull with a merge, and the push again"
need "there's a second clone of node1's repository in greg's home" '[ -n "$(others)" ]'
need "main in node1's repository has a merge commit" "rg rev-list --merges main | grep -q ."
need "$C has pushed everything: its main is node1's main" "[ \"\$(g -C $C rev-parse main)\" = \"\$(rg rev-parse main)\" ]"
