H=$(state_get home)
B=$H/big-etc.txt
norm() { sed 's#//*#/#g; s/[[:space:]]*$//' "$@"; }
# Each listed path is a regular file under /etc bigger than 100 KiB.
all_big() {
	local p
	while read -r p; do
		case $p in /etc/*) ;; *) return 1 ;; esac
		[ -n "$(find "$p" -maxdepth 0 -type f -size +100k 2>/dev/null)" ] || return 1
	done < <(norm "$B")
}
# Every such file student can find is listed.
none_missing() {
	local p
	while read -r p; do
		norm "$B" | grep -qxF "$p" || return 1
	done < <(runuser -u student -- find /etc -type f -size +100k 2>/dev/null | norm)
}

task 1 "~/bash-users.txt lists exactly the users with shell /bin/bash"
need "$H/bash-users.txt exists" '[ -f "$H/bash-users.txt" ]'
need "it holds the names of the users whose shell is /bin/bash, one per line, and nothing else" \
	'[ "$(norm "$H/bash-users.txt" | sort)" = "$(awk -F: "\$7 == \"/bin/bash\" {print \$1}" /etc/passwd | sort)" ]'

task 2 "~/big-etc.txt: regular files under /etc over 100 KiB, no errors"
need "$B exists and lists something" '[ -s "$B" ]'
need "it has no Permission denied lines" '! grep -qi "permission denied" "$B"'
need "every line is a regular file under /etc bigger than 100 KiB" all_big
need "it lists every such file student can find" none_missing

task 3 "sed changed #Port 22 to Port 2222 in ~/sshd.copy, with a .bak"
need "$H/sshd.copy.bak is an unchanged copy of /etc/ssh/sshd_config" 'cmp -s "$H/sshd.copy.bak" "$LAB_STATE/sshd_config" || cmp -s "$H/sshd.copy.bak" /etc/ssh/sshd_config'
need "$H/sshd.copy has Port 2222 and no #Port 22" 'grep -qx "Port 2222" "$H/sshd.copy" && ! grep -qx "#Port 22" "$H/sshd.copy"'
need "diff ~/sshd.copy.bak ~/sshd.copy shows one line changed, as a c change" \
	'd=$(diff "$H/sshd.copy.bak" "$H/sshd.copy"); [ "$(wc -l <<<"$d")" = 4 ] && head -n1 <<<"$d" | grep -Eq "^[0-9]+c[0-9]+$"'
