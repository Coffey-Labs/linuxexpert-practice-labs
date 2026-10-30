regular=$(awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' /etc/passwd | sort)
active() { grep -v -E '^\s*(#|$)' /etc/ssh/sshd_config; }
# The three most common words in the bash man page.
top=$(MANWIDTH=80 man bash 2>/dev/null | tr -cs 'A-Za-z' '\n' | tr 'A-Z' 'a-z' | sort | uniq -c | sort -rn | head -n3 | awk '{print $2}')

task 1 "The regular users (UID 1000 to 59999)"
need "/root/lab-answers/1 lists exactly the regular users: $(echo $regular)" '[ "$(awk "NF {print \$1}" /root/lab-answers/1 | sort)" = "$regular" ]'

task 2 "sshd_config without comments in /tmp/sshd.active, and its line count"
need "/tmp/sshd.active is sshd_config without comments and blank lines" 'active | cmp -s - /tmp/sshd.active'
need "/root/lab-answers/2 has the count, $(active | wc -l)" '[ "$(answer 2 | tr -dc 0-9)" = "$(active | wc -l)" ]'

task 3 "PermitRootLogin no in /tmp/s.conf, the original in /tmp/s.conf.bak"
need "/tmp/s.conf.bak is a copy of sshd_config" 'cmp -s /etc/ssh/sshd_config /tmp/s.conf.bak'
need "/tmp/s.conf has the line PermitRootLogin no" 'grep -qx "PermitRootLogin no" /tmp/s.conf'
need "only the PermitRootLogin line changed" '
	[ "$(wc -l </tmp/s.conf)" = "$(wc -l </etc/ssh/sshd_config)" ] &&
	! diff /tmp/s.conf.bak /tmp/s.conf | grep "^[<>]" | grep -v PermitRootLogin | grep -q .'

task 4 "The most common word in the bash man page"
need "man bash works" '[ -n "$top" ]'
need "/root/lab-answers/4 has the most common word" '[ -n "$(answer 4)" ] && grep -qxF "$(answer 4)" <<<"$top"'
