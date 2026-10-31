SC=/usr/bin/systemctl
may() { local u=$1; shift; sudo -l -U "$u" "$@" >/dev/null 2>&1; }
# Drop-ins sudo reads (no dot, no ~) that weren't there at setup and name alice.
alice_dropin() {
	local f
	for f in /etc/sudoers.d/*; do
		[ -f "$f" ] || continue
		case ${f##*/} in *.* | *~) continue ;; esac
		grep -qxF "${f##*/}" "$LAB_STATE/sudoers-d" && continue
		grep -qw alice "$f" && return 0
	done
	return 1
}
only_ssh() {
	! may alice /usr/bin/id && ! may alice /bin/bash && ! may alice $SC stop ssh &&
		! may alice $SC restart cron && ! may alice $SC restart ssh.socket && ! may alice $SC edit ssh
}
no_password() {
	local l
	l=$(sudo -l -U alice | sed -n '/may run the following/,$p')
	grep -q NOPASSWD <<<"$l" && ! grep -Eq '(^|[^O])PASSWD:' <<<"$l" &&
		! runuser -u alice -- sudo -n $SC status ssh 2>&1 >/dev/null </dev/null | grep -qi "password is required"
}

task 1 "alice may restart and check ssh as root, no password, nothing else"
need "visudo -c reports every file parsed OK" 'visudo -c'
need "a drop-in in /etc/sudoers.d (with no dot in its name) names alice" alice_dropin
need "alice may run systemctl restart ssh as root" 'may alice $SC restart ssh'
need "alice may run systemctl status ssh as root" 'may alice $SC status ssh'
need "alice needs no password for them (NOPASSWD)" no_password
need "alice may run nothing else (not id, a shell, or other systemctl commands)" only_ssh

task 2 "bob is an administrator through group sudo"
need "groups bob includes sudo" 'id -nG bob | grep -qw sudo'
need "sudo -l -U bob shows (ALL : ALL) ALL" 'sudo -l -U bob | grep -qF "(ALL : ALL) ALL"'
need "bob still needs his password (no NOPASSWD)" '! sudo -l -U bob | grep -q NOPASSWD'
need "no sudoers file names bob" '! grep -rqw bob /etc/sudoers /etc/sudoers.d'

task 3 "sudo skips alice.conf: its answer saved, file renamed back"
need "/root/lab-answers/3 has what sudo said: alice is not allowed to run sudo" 'grep -qi "not allowed to run sudo" /root/lab-answers/3'
need "no file with a dot (or ending in ~) in /etc/sudoers.d names alice" '! find /etc/sudoers.d -type f \( -name "*.*" -o -name "*~" \) -exec grep -qw alice {} \; -print | grep -q .'
need "alice's drop-in is back in use" 'alice_dropin && may alice $SC restart ssh'
