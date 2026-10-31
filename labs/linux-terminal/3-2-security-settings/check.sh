H=$(state_get home)
saved=$LAB_STATE/saved
login_run() { su - "$1" -c "$2" </dev/null 2>/dev/null; }
# An interactive, non-login bash of USER's, started clean.
interactive_umask() {
	local h; h=$(getent passwd "$1" | cut -d: -f6)
	runuser -u "$1" -- env -i HOME="$h" USER="$1" LOGNAME="$1" PATH=/usr/bin:/bin TERM=dumb bash -i -c umask </dev/null 2>/dev/null | tail -n1
}
new_files() {	# DIR LIST: files in DIR that weren't there at setup
	local f
	for f in "$1"/*; do
		[ -f "$f" ] || continue
		grep -qxF "${f##*/}" "$2" 2>/dev/null || printf '%s\n' "$f"
	done
}

task 1 "alice limited to 50 processes, soft and hard, in a file of its own"
need "su - alice -c 'ulimit -u; ulimit -Hu' prints 50 twice" '[ "$(login_run alice "ulimit -u; ulimit -Hu" | tail -n2 | paste -sd " ")" = "50 50" ]'
need "a new file in /etc/security/limits.d sets alice's nproc" 'new_files /etc/security/limits.d "$LAB_STATE/limits-d" | xargs -r grep -hEv "^[[:space:]]*#" | grep -Eq "^[[:space:]]*alice[[:space:]].*nproc"'
need "/etc/security/limits.conf is unchanged" 'cmp -s /etc/security/limits.conf "$saved/limits.conf"'
need "other users are unchanged: student's ulimit -u isn't 50" '[ "$(login_run student "ulimit -u" | tail -n1)" != 50 ]'

task 2 "Every login shell prints Authorized use only, from /etc/profile.d"
need "su - alice -c true prints Authorized use only" 'login_run alice true | grep -q "Authorized use only"'
need "a new .sh file in /etc/profile.d prints it" 'new_files /etc/profile.d "$LAB_STATE/profile-d" | grep "\.sh$" | xargs -r grep -l "Authorized use only" | grep -q .'
need "/etc/profile is unchanged" 'cmp -s /etc/profile "$saved/profile"'

task 3 "student's interactive shells have umask 077"
need "a new interactive bash of student's prints umask 0077" '[ "$(interactive_umask student)" = 0077 ]'
need "a login shell of student's has umask 0077 too" '[ "$(su - student -c "bash -i -c umask" </dev/null 2>/dev/null | tail -n1)" = 0077 ]'
need "a file student touches is -rw-------" 'f=$H/.le-check-$$; runuser -u student -- env -i HOME="$H" PATH=/usr/bin:/bin bash -i -c "touch $f" </dev/null 2>/dev/null; m=$(stat -c %a "$f"); rm -f "$f"; [ "$m" = 600 ]'
need "other users keep their umask: alice's isn't 0077" '[ "$(interactive_umask alice)" != 0077 ]'
