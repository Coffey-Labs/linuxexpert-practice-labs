g() { git -C /root/repo "$@"; }
gc() { HOME=/root git config --global --get "$1"; }
msg_commit() { g log --format=%H --fixed-strings --grep="$2" "$1" 2>/dev/null | head -n1; }

task 1 "Git configured, ~/repo with the first commit"
need "git is installed" 'command -v git'
need "your name and email are set globally" '[ -n "$(gc user.name)" ] && [ -n "$(gc user.email)" ]'
need "the default branch name is main" '[ "$(gc init.defaultBranch)" = main ]'
need "~/repo is a repository with a branch main" 'g rev-parse -q --verify refs/heads/main'
need "main has the commit Add hello script" '[ -n "$(msg_commit main "Add hello script")" ]'
need "hello.sh is committed as an executable file" 'g ls-tree "$(msg_commit main "Add hello script")" hello.sh | grep -q "^100755"'

task 2 "*.log ignored, greeting changed and committed"
need "main has the commit Greet the world, ignore logs" '[ -n "$(msg_commit main "Greet the world, ignore logs")" ]'
need ".gitignore with *.log is committed on main" 'g show main:.gitignore | grep -qxF "*.log"'
need "Git ignores run.log" '[ -e /root/repo/run.log ] && g check-ignore -q run.log && [ -z "$(g ls-files run.log)" ]'
need "hello.sh on main says hello, world" 'g show main:hello.sh | grep -q "hello, world"'

task 3 "Branch feature prints the date, main doesn't"
need "branch feature exists" 'g rev-parse -q --verify refs/heads/feature'
need "feature has the commit Print the date" '[ -n "$(msg_commit feature "Print the date")" ]'
need "hello.sh on feature has a date line" 'g show feature:hello.sh | grep -qx date'
need "hello.sh on main has no date line" '! g show main:hello.sh | grep -qx date'
