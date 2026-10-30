counts_ok() { [ "$(awk 'NF >= 2 {print $1, $2}' /root/lab-answers/2 2>/dev/null | sort)" = "$(cat "$LAB_STATE/counts")" ]; }
same_matches() {
	local b e
	b=$(sed -n 1p /root/lab-answers/4 2>/dev/null) e=$(sed -n 2p /root/lab-answers/4 2>/dev/null)
	# Strip quotes the student may have kept.
	b=${b#\'}; b=${b%\'}; e=${e#\'}; e=${e%\'}
	[ -n "$b" ] && [ -n "$e" ] && [ "$b" != "$e" ] || return 1
	local mb me
	mb=$(grep -e "$b" /root/regex/access.log) && me=$(grep -E -e "$e" /root/regex/access.log) || return 1
	[ "$mb" = "$me" ]
}

task 1 "sshd_config without comments or blank lines"
need "/root/regex/sshd-active.txt has exactly the lines that aren't comments or blank" '[ -s /root/regex/sshd-active.txt ] && grep -Ev "^(#|$)" /etc/ssh/sshd_config | cmp -s - /root/regex/sshd-active.txt'

task 2 "IPv4 addresses in the log counted"
need "/root/lab-answers/2 has the count of each address" counts_ok

task 3 "A copy of sshd_config with port 2222, and a .bak of the original"
need "/root/sshd_config.bak is the original" 'cmp -s /root/sshd_config.bak /etc/ssh/sshd_config'
need "/root/sshd_config sets Port 2222" 'grep -Eq "^Port[[:space:]]+2222[[:space:]]*$" /root/sshd_config'
need "only the port line changed" '[ "$(diff /root/sshd_config.bak /root/sshd_config | grep -c "^[<>]")" -le 2 ]'

task 4 "One pattern as a basic and an extended regex"
need "the two patterns differ and match the same lines of access.log" same_matches
