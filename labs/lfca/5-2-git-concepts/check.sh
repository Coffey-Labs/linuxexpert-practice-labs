g() { git -C /root/project "$@"; }
gc() { HOME=/root git config --global --get "$1"; }
# The newest commit made in ~/app-copy itself (not cloned or pulled).
copy_commit() { git -C /root/app-copy log -g --format='%H %gs' 2>/dev/null | awk '$2 == "commit:" || $2 == "commit" {print $1; exit}'; }
remote_is_app() { local u; for u in $(g remote 2>/dev/null); do g remote get-url "$u" | grep -Eq '(^|/)app\.git/?$' && return 0; done; return 1; }
reverted() {
	local c t
	for c in $(g log --format=%H --grep='^Revert "' main); do
		t=$(g log -1 --format=%B "$c" | grep -Eo 'reverts commit [0-9a-f]{7,40}' | awk '{print $3}')
		[ -n "$t" ] && g merge-base --is-ancestor "$t" "$c" && return 0
	done
	return 1
}

task 1 "Git configured; ~/project with three commits on main"
need "git is installed" 'command -v git'
need "your name and email are set globally" '[ -n "$(gc user.name)" ] && [ -n "$(gc user.email)" ]'
need "~/project is a repository with a branch main" 'g rev-parse -q --verify refs/heads/main'
need "main has at least three commits" '[ "$(g rev-list --count main)" -ge 3 ]'

task 2 "A branch merged into main, conflict resolved"
need "main has a merge commit" '[ -n "$(g rev-list --merges main)" ]'
need "no merge is left half done" '[ ! -e /root/project/.git/MERGE_HEAD ]'
need "no conflict markers are committed" '! g grep -qE "^(<<<<<<<|>>>>>>>)( |$)" main'

task 3 "~/app.git as a remote, a change pushed from ~/app-copy and pulled back"
need "~/app.git is a bare repository" '[ "$(git --git-dir=/root/app.git rev-parse --is-bare-repository 2>/dev/null)" = true ]'
need "~/app.git's default branch (its HEAD) is main" '[ "$(git --git-dir=/root/app.git symbolic-ref HEAD 2>/dev/null)" = refs/heads/main ]'
need "~/project has ~/app.git as a remote" remote_is_app
need "~/app-copy is a clone of ~/app.git" 'git -C /root/app-copy remote get-url origin | grep -Eq "(^|/)app\.git/?$"'
need "a commit was made in ~/app-copy" '[ -n "$(copy_commit)" ]'
need "it was pushed to ~/app.git" 'git --git-dir=/root/app.git merge-base --is-ancestor "$(copy_commit)" main'
need "it was pulled into ~/project's main" 'g merge-base --is-ancestor "$(copy_commit)" main'

task 4 "A bad commit undone with git revert"
need "main has a Revert commit for an earlier commit" reverted
