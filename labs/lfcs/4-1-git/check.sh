R=/srv/git/app.git A=/root/app
M0=$(state_get main0) FW=$(state_get workers) BAD=$(state_get bad)
rg() { git -C "$R" "$@"; }
ag() { git -C "$A" "$@"; }

# A merge on main that brought in feature/workers after main changed the
# workers line itself (so there was a conflict to resolve).
conflict_merge() {
	local c
	for c in $(ag rev-list --merges "$M0"..refs/heads/main); do
		ag merge-base --is-ancestor "$FW" "$c" || continue
		ag show "$c^1:app.conf" | grep -Eq '^workers *= *2 *$' && continue
		return 0
	done
	return 1
}

task 1 "Branch feature/motd with a new file, pushed"
need "/srv/git/app.git has a branch feature/motd" 'rg rev-parse -q --verify refs/heads/feature/motd'
need "feature/motd adds a new file" '[ -n "$(rg diff --name-only --diff-filter=A "$M0" refs/heads/feature/motd)" ]'

task 2 "feature/workers merged into main, conflict resolved"
need "/root/app is a clone of /srv/git/app.git" 'ag remote -v | grep -q "srv/git/app.git"'
need "main in /root/app contains feature/workers" 'ag merge-base --is-ancestor "$FW" refs/heads/main'
need "main has a merge commit after changing the workers line itself" conflict_merge
need "app.conf on main has no conflict markers" '! ag show refs/heads/main:app.conf | grep -Eq "^(<<<<<<<|=======|>>>>>>>)"'

task 3 "The commit that changed the timeout line reverted"
need "main still has its original history" 'ag merge-base --is-ancestor "$M0" refs/heads/main'
need "main has a commit that reverts it" 'ag log --format=%B "$M0"..refs/heads/main | grep -Eqi "^revert|$BAD"'
need "timeout in app.conf on main is back to 30" 'ag show refs/heads/main:app.conf | grep -Eq "^timeout *= *30 *$"'

task 4 ".log files ignored, debug.log no longer tracked"
need "debug.log is not tracked on main" '[ -z "$(ag ls-tree --name-only refs/heads/main -- debug.log)" ]'
need "debug.log is still in /root/app" '[ -f /root/app/debug.log ]'
need ".gitignore is committed on main" 'ag cat-file -e refs/heads/main:.gitignore'
need "Git ignores .log files" 'ag check-ignore -q debug.log && ag check-ignore -q other.log'

task 5 "Annotated tag v1.0, pushed"
need "/srv/git/app.git has tag v1.0" 'rg rev-parse -q --verify refs/tags/v1.0'
need "v1.0 is an annotated tag (with a message)" '[ "$(rg cat-file -t refs/tags/v1.0)" = tag ]'
