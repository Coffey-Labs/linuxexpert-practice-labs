sshd_ok() {
	local a=/root/lab-answers/1 f ok_run=''
	grep -Eq '(^|[[:space:]])(/usr)?/sbin/sshd([[:space:]]|$)' $a || return 1
	grep -q '/etc/ssh/sshd_config' $a || return 1
	grep -Eq 'journal|/var/log/' $a || return 1
	for f in $(grep -oE '/run/[^[:space:]]+' $a); do [ -e "$f" ] && ok_run=1; done
	[ -n "$ok_run" ] || return 1
	for f in $(grep -oE '/usr/share/man/[^[:space:]]+' $a); do [ -e "$f" ] && return 0; done
	return 1
}
prune_ok() {
	local p
	p=$(sed -n 's/^[[:space:]]*PRUNEPATHS[[:space:]]*=[[:space:]]*"\(.*\)"/\1/p' /etc/updatedb.conf 2>/dev/null)
	printf ' %s ' "$p" | grep -Eq ' /srv/archive/? '
}
db() { ls /var/lib/plocate/plocate.db /var/lib/mlocate/mlocate.db 2>/dev/null | head -n1; }

task 1 "Where sshd's files live"
need "/root/lab-answers/1 has sshd's program, config, logs, a runtime file and a man page" sshd_ok

task 2 "locate and locate -e after deleting a file"
need "/root/lab-answers/2 names the one that still lists it" '[ "$(answer 2)" = locate ]'

task 3 "/srv/archive left out of the locate database"
need "PRUNEPATHS in /etc/updatedb.conf has /srv/archive" prune_ok
need "updatedb has run since" '[ "$(stat -c %Y "$(db)")" -ge "$(stat -c %Y /etc/updatedb.conf)" ]'
need "locate no longer finds the files in /srv/archive" '[ -d /srv/archive ] && ! locate le-archive-report'

task 4 "type -a for cd"
need "/root/lab-answers/4 has what type -a cd prints" 'grep -q "cd is a shell builtin" /root/lab-answers/4'

task 5 "locate and find timed" self
