B=/usr/local/bin
# out USER CMD...: CMD's output, run as USER.
out() { local u=$1; shift; timeout 20 runuser -u "$u" -- "$@" 2>/dev/null; }
# Task 4: stop chronyd, run the script twice, put chronyd back as it was.
chrony_test() {
	local was=0 r=1
	systemctl is-active --quiet chronyd && was=1
	systemctl stop chronyd
	timeout 30 $B/start-chronyd >/dev/null 2>&1
	sleep 1
	if systemctl is-active --quiet chronyd; then
		[ -z "$(timeout 30 $B/start-chronyd 2>&1)" ] && systemctl is-active --quiet chronyd && r=0
	fi
	[ "$was" = 1 ] && systemctl start chronyd
	return $r
}
chrony_quiet() {
	systemctl start chronyd
	[ -z "$(timeout 30 $B/start-chronyd 2>&1)" ] && systemctl is-active --quiet chronyd
}

task 1 "kind prints file, directory or missing"
need "$B/kind exists and is executable" '[ -x $B/kind ]'
need "kind /etc prints directory" '[ "$(out root $B/kind /etc)" = directory ]'
need "kind /etc/hosts prints file" '[ "$(out root $B/kind /etc/hosts)" = file ]'
need "kind /nope prints missing" '[ "$(out root $B/kind /nope)" = missing ]'

task 2 "amiroot: root and 0 as root, not root and 1 otherwise"
need "$B/amiroot exists and everyone can run it" '[ -x $B/amiroot ] && [ "$(stat -c %A $B/amiroot | cut -c10)" = x ]'
need "as root it prints root" '[ "$(out root $B/amiroot)" = root ]'
need "as root it exits 0" 'out root $B/amiroot'
need "as another user it prints not root" '[ "$(out nobody $B/amiroot)" = "not root" ]'
need "as another user it exits 1" 'out nobody $B/amiroot; [ $? = 1 ]'

task 3 "userexists says whether a user exists"
need "$B/userexists exists and is executable" '[ -x $B/userexists ]'
need "userexists root prints root exists" '[ "$(out root $B/userexists root)" = "root exists" ]'
need "userexists nosuchuser prints nosuchuser does not exist" '[ "$(out root $B/userexists nosuchuser)" = "nosuchuser does not exist" ]'

task 4 "start-chronyd starts chronyd only if it isn't running"
need "$B/start-chronyd exists and is executable" '[ -x $B/start-chronyd ]'
need "with chronyd running, it prints nothing and chronyd stays active" chrony_quiet
need "with chronyd stopped, it starts it; run again, it prints nothing" chrony_test
