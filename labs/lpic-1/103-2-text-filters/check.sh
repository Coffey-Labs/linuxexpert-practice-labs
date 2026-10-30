# Normalized "COUNT WORD" lines, sorted.
norm() { awk 'NF >= 2 {print $1, $2}' "$@" | sort; }
fruit_ok() {
	[ "$(norm /root/lab-answers/1 2>/dev/null)" = "$(printf '2 apple\n2 banana\n1 cherry\n' | sort)" ]
}
shells_ok() {
	local want
	want=$(cut -d: -f7 /etc/passwd | sort | uniq -c | sort -rn)
	[ "$(norm /root/lab-answers/2 2>/dev/null)" = "$(printf '%s\n' "$want" | norm)" ] || return 1
	# Most common first: the first line has the highest count.
	[ "$(awk 'NF {print $1; exit}' /root/lab-answers/2)" = "$(printf '%s\n' "$want" | awk '{print $1; exit}')" ]
}
split_ok() {
	local d=/root/filters/split n=0 f last=''
	for f in "$d"/*; do
		[ -f "$f" ] || continue
		[ -n "$last" ] && { [ "$(wc -l <"$last")" -eq 100 ] || return 1; }
		last=$f n=$((n + 1))
	done
	[ "$n" -ge 2 ] && [ "$(wc -l <"$last")" -le 100 ] || return 1
	cat "$d"/* | cmp -s - /root/filters/joined.log
}

task 1 "fruit.txt and a count of lines per fruit"
need "/root/filters/fruit.txt has the chapter's five lines" '[ "$(cat /root/filters/fruit.txt)" = "$(printf "apple 3\nbanana 12\ncherry 7\napple 5\nbanana 1")" ]'
need "/root/lab-answers/1 counts 2 apple, 2 banana and 1 cherry" fruit_ok

task 2 "Accounts per login shell, most common first"
need "/root/lab-answers/2 counts each shell in /etc/passwd, most common first" shells_ok

task 3 "The file with Windows line endings"
need "/root/lab-answers/3 names the report file with Windows line endings" '[ "$(basename "$(answer 3)")" = "$(state_get crlf)" ]'

task 4 "A log split into 100-line pieces and joined again"
need "/root/filters/joined.log exists" '[ -s /root/filters/joined.log ]'
need "/root/filters/split/ holds two or more pieces of 100 lines (the last one up to 100), and they join up to joined.log" split_ok

task 5 "logger hello seen in the log"
need "the log has a hello message from logger since the lab started" 'journalctl -q --no-pager --since "@$(state_get since)" -o cat | grep -qx hello'
