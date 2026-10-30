# A fresh login shell, as the guide tests it.
login_env() { sudo -niu "$1" printenv "$2" </dev/null 2>/dev/null | tail -n1; }
lab_ssh() {
	ssh -n -i "$LAB_STATE/ssh-key" -o BatchMode=yes -o StrictHostKeyChecking=no \
		-o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=10 "$@" 2>/dev/null | tail -n1
}
PROXY=http://proxy.example.org:3128

# Task 2 is tried on a new user, removed again at once.
new_readme='' new_alias=''
userdel -r le-newuser >/dev/null 2>&1
if useradd -m le-newuser >/dev/null 2>&1; then
	[ -f "$(getent passwd le-newuser | cut -d: -f6)/README" ] && new_readme=yes
	new_alias=$(sudo -niu le-newuser bash -ic 'alias lt' </dev/null 2>/dev/null | tail -n1)
	pkill -KILL -u le-newuser 2>/dev/null
	userdel -r le-newuser >/dev/null 2>&1
fi

task 1 "COMPANY=example in every user's login shell, /etc/profile unchanged"
need "/etc/profile is unchanged" '[ "$(sha256sum </etc/profile)" = "$(state_get profile-sum)" ]'
need "sudo -iu erin printenv COMPANY prints example" '[ "$(login_env erin COMPANY)" = example ]'
need "sudo -iu frank printenv COMPANY prints example" '[ "$(login_env frank COMPANY)" = example ]'
need "root's login shell has COMPANY=example too" '[ "$(login_env root COMPANY)" = example ]'

task 2 "New users get alias lt='ls -ltr' and a README"
need "a new user (useradd -m) gets a README in the home directory" '[ "$new_readme" = yes ]'
need "a new user's interactive bash has alias lt='ls -ltr'" '[ "$new_alias" = "alias lt='"'"'ls -ltr'"'"'" ]'

task 3 "/opt/tools/bin in erin's PATH, not in frank's"
need "erin's login PATH includes /opt/tools/bin" 'login_env erin PATH | tr : "\n" | grep -qx /opt/tools/bin'
need "frank's login PATH doesn't include /opt/tools/bin" 'login_env frank PATH | tr : "\n" | grep -q . && ! login_env frank PATH | tr : "\n" | grep -qx /opt/tools/bin'

task 4 "HTTP_PROXY for every session, including ssh host command"
need "ssh erin@localhost printenv HTTP_PROXY prints $PROXY" '[ "$(lab_ssh erin@localhost printenv HTTP_PROXY)" = "$PROXY" ]'
need "ssh frank@localhost printenv HTTP_PROXY prints $PROXY" '[ "$(lab_ssh frank@localhost printenv HTTP_PROXY)" = "$PROXY" ]'
need "frank's login shell has it too" '[ "$(login_env frank HTTP_PROXY)" = "$PROXY" ]'
