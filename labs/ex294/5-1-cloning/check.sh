nodes_wait 60 || true
R=/srv/git/playbooks.git
C=/home/greg/playbooks
# g CMD: run git CMD as greg, over SSH with his key and no prompts.
g() {
	setsid -w timeout 60 runuser -u greg -- env HOME=/home/greg \
		GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10" \
		git "$@" </dev/null
}
# origin_ok DIR: DIR is a clone whose origin is node1's repository over SSH.
origin_ok() {
	g -C "$1" remote get-url origin 2>/dev/null |
		grep -Eq '^(ssh://)?([^@/]+@)?(node1(\.lab\.example)?|10\.99\.1\.11)(:[0-9]+)?[:/]+srv/git/playbooks\.git/?$'
}
# The other clones of it in greg's home.
others() {
	find /home/greg -maxdepth 3 -name .git -type d 2>/dev/null | while read -r d; do
		d=${d%/.git}; [ "$d" = "$C" ] && continue
		origin_ok "$d" && printf '%s\n' "$d"
	done
}
log() { g -C "$1" log --oneline 2>/dev/null; }

task 1 "A bare repository on node1, cloned over SSH into /home/greg/playbooks, on main"
need "$R on node1 is a bare repository" "[ \"\$(in_node node1 git --git-dir=$R rev-parse --is-bare-repository)\" = true ]"
need "its default branch is main" "[ \"\$(in_node node1 git --git-dir=$R symbolic-ref HEAD)\" = refs/heads/main ]"
need "$C is a Git clone" "[ -d $C/.git ]"
need "its origin is devops@node1:$R (or another SSH URL for it)" "origin_ok $C"
need "greg can reach origin over SSH from $C (git ls-remote origin)" "g -C $C ls-remote origin"
need "$C is on the branch main" "[ \"\$(g -C $C symbolic-ref HEAD)\" = refs/heads/main ]"

task 2 "greg's Git name and email, set globally, on a pushed README.md"
need "user.name is set in greg's global Git config" 'runuser -l greg -c "git config --global user.name" | grep -q .'
need "user.email is set in greg's global Git config" 'runuser -l greg -c "git config --global user.email" | grep -q @'
need "main in node1's repository has README.md" "in_node node1 git --git-dir=$R ls-tree --name-only main | grep -qx README.md"
need "a commit on node1's main has greg's name and email as the author" 'in_node node1 git --git-dir=$R log --format="%an <%ae>" main | grep -qxF "$(runuser -l greg -c "git config --global user.name") <$(runuser -l greg -c "git config --global user.email")>"'

task 3 "A second clone of the repository, with the same log"
need "another directory in greg's home is a clone of node1's $R" '[ -n "$(others)" ]'
need "it has the same git log --oneline as $C, with a commit in it" '[ -n "$(log $C)" ] && for d in $(others); do [ "$(log "$d")" = "$(log $C)" ] && exit 0; done; exit 1'
