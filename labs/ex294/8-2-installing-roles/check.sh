nodes_wait 60 || true
# ans CMD: run CMD as greg in his project directory.
ans() { timeout 180 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
P=/home/greg/ansible
REPO=/srv/git/chrony-role.git
# listed: what ansible-galaxy role list -p roles shows under the project's roles.
listed() { ans ansible-galaxy role list -p roles 2>/dev/null | awk '/^# /{s = ($2 == "/home/greg/ansible/roles")} s && /^- /'; }
# served ROLE: http://node1/roles/ROLE.tar.gz is a tarball with the role at its top.
served() { curl -sf -m 10 "http://node1/roles/$1.tar.gz" | tar -tz 2>/dev/null | grep -Eq "^(\./)?$1/meta/main.yml$"; }
git_() { runuser -u greg -- git --git-dir=$REPO "$@"; }

task 1 "motd and issue: tarballs on node1's web server, installed from roles/requirements.yml"
for r in motd issue; do
	need "http://node1/roles/$r.tar.gz has the role $r at its top" "served $r"
	need "$P/roles/requirements.yml installs $r from that URL" "grep -Eq 'http://(node1|node1\.lab\.example|10\.99\.1\.11)/roles/$r\.tar\.gz' $P/roles/requirements.yml"
	need "ansible-galaxy role list -p roles lists $r in $P/roles" "listed | grep -q '^- $r,'"
	need "ansible-galaxy installed it (roles/$r/meta/.galaxy_install_info)" "[ -f $P/roles/$r/meta/.galaxy_install_info ]"
done

task 2 "chrony from the Git repository, branch devel"
need "ansible-galaxy role list -p roles shows chrony, devel" "listed | grep -qx -- '- chrony, devel'"

task 3 "A change to chrony's devel branch, installed with --force"
need "the devel branch of $REPO has a commit the lab didn't make" '[ "$(git_ rev-parse devel)" != "$(state_get devel)" ]'
need "the installed chrony role has the files of that commit" 'T=$(mktemp -d) && git_ archive devel | tar -x -C "$T" && diff -r -x .galaxy_install_info "$T" $P/roles/chrony; r=$?; rm -rf "$T"; exit $r'
