SINCE=$(state_get since)
# refused: a login of tess's refused since setup, in the journal or a log
# file.
refused() {
	local f n re="nologin|refused|denied|not allowed"
	journalctl -q --no-pager --since "$SINCE" 2>/dev/null | grep -Ei "$re" | grep -qw tess && return 0
	for f in /var/log/secure /var/log/auth.log; do
		[ -f "$f" ] || continue
		n=$(state_get "size$(echo "$f" | tr / _)"); n=${n:-0}
		[ "$(stat -c %s "$f")" -ge "$n" ] || n=0
		tail -c +$((n + 1)) "$f" | grep -Ei "$re" | grep -qw tess && return 0
	done
	return 1
}

task 1 "legacy-echo stopped, disabled and masked"
need "legacy-echo isn't running" '! active legacy-echo'
need "nothing listens on port 7007" '! listening 7007 tcp'
need "legacy-echo is masked" '[ "$(systemctl is-enabled legacy-echo 2>/dev/null)" = masked ]'

task 2 "A login refused because of /etc/nologin, and /etc/nologin removed"
need "/etc/nologin is gone" '[ ! -e /etc/nologin ]'
need "the logs show tess refused while /etc/nologin existed" refused
need "tess can log in again" 'timeout 15 ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -i /root/lab-keys/tess tess@localhost "echo le-ok" </dev/null | grep -q le-ok'

task 3 "testuser's shell is nologin"
need "testuser's shell is /usr/sbin/nologin" 'getent passwd testuser | cut -d: -f7 | grep -Eqx "(/usr)?/sbin/nologin"'
