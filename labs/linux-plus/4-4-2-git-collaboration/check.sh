g() { git -C /root/repo "$@"; }
r() { git -C /root/remote.git "$@"; }
FEAT=$(state_get feature)
readme_commit() { r log --format=%H --diff-filter=A refs/heads/main -- README 2>/dev/null | tail -n1; }
squash() { g log --format=%H --fixed-strings --grep="Print the date (squashed)" main 2>/dev/null | tail -n1; }

task 1 "~/remote.git with main and feature, cloned to ~/repo2"
need "~/remote.git is a bare repository" '[ "$(r rev-parse --is-bare-repository)" = true ]'
need "it has branches main and feature" 'r rev-parse -q --verify refs/heads/main && r rev-parse -q --verify refs/heads/feature'
need "feature there is the feature branch from ~/repo" '[ "$(r rev-parse refs/heads/feature)" = "$FEAT" ]'
need "~/repo has origin pointing at ~/remote.git" 'g remote get-url origin | grep -q "remote\.git$"'
need "main in ~/repo tracks origin/main" '[ "$(g rev-parse --abbrev-ref main@{upstream})" = origin/main ]'
need "~/repo2 is a clone of ~/remote.git" 'git -C /root/repo2 remote get-url origin | grep -q "remote\.git$"'

task 2 "README pushed from ~/repo2 and pulled into ~/repo"
need "~/remote.git's main has a commit adding README" '[ -n "$(readme_commit)" ]'
need "README there says Lab scripts" 'r show refs/heads/main:README | grep -qx "Lab scripts"'
need "main in ~/repo has that commit" 'g merge-base --is-ancestor "$(readme_commit)" main'

task 3 "Squash-merged feature, tagged v1.0"
need "main has a commit Print the date (squashed)" '[ -n "$(squash)" ]'
need "it's a squash, not a merge (one parent)" '[ "$(g rev-list --parents -n1 "$(squash)" | wc -w)" = 2 ]'
need "it adds the date line" 'g show "$(squash)" -- hello.sh | grep -qx "+date"'
need "feature itself isn't merged into main" '! g merge-base --is-ancestor "$FEAT" main'
need "v1.0 is an annotated tag" '[ "$(g cat-file -t refs/tags/v1.0)" = tag ]'
need "v1.0 points at the squashed commit" '[ "$(g rev-parse "v1.0^{commit}")" = "$(squash)" ]'

task 4 "Oops undone, squashed commit reverted"
need "main has no commit Oops" '! g log --format=%s main | grep -qx Oops'
need "the latest commit on main reverts the squashed commit" 'g log -1 --format=%B main | grep -q "This reverts commit $(squash)"'
need "hello.sh on main has no date or wip line" '! g show main:hello.sh | grep -Eqx "date|wip"'
need "the working tree is clean" '[ -z "$(g status --porcelain)" ]'
