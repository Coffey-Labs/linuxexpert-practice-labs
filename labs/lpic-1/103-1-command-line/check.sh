line() { sed -n "$1p" /root/lab-answers/1 2>/dev/null | sed 's/[[:space:]]*$//'; }
# hello.sh in root's home or a user's: executable, a #! line, two lines or more.
script_ok() {
	local f
	for f in /root/hello.sh /home/*/hello.sh; do
		[ -f "$f" ] && [ -x "$f" ] && head -n1 "$f" | grep -q '^#!' && [ "$(grep -c . "$f")" -ge 2 ] && return 0
	done
	return 1
}
builtins_ok() {
	local a; a=$(tr -s ',[:space:]' '\n\n' </root/lab-answers/4 2>/dev/null)
	printf '%s\n' "$a" | grep -qx cd && printf '%s\n' "$a" | grep -qx echo &&
		! printf '%s\n' "$a" | grep -qxE 'ls|ssh'
}

task 1 "The four echo outputs"
need "line 1 of /root/lab-answers/1 is what echo '\$HOME' prints" '[ "$(line 1)" = "\$HOME" ]'
need "line 2 is what echo \"\$HOME\" prints for root" '[ "$(line 2)" = /root ]'
need "line 3 is what echo \\\$HOME prints" '[ "$(line 3)" = "\$HOME" ]'
need "line 4 is what echo \"It's \$USER\" prints for root" '[ "$(line 4)" = "It'\''s root" ]'

task 2 "An exported variable seen by a child shell" self

task 3 "hello.sh runs with ./; the reason it doesn't run by name"
need "an executable hello.sh with a #! line and two lines or more is in a home directory" script_ok
need "/root/lab-answers/3 explains it with PATH" 'grep -qi path /root/lab-answers/3'

task 4 "The shell builtins among cd, ls, echo and ssh"
need "/root/lab-answers/4 lists cd and echo, and not ls or ssh" builtins_ok

task 5 "The man page for the crontab file format"
need "/root/lab-answers/5 opens section 5 of crontab" 'grep -Eq "(^|[^0-9])5([^0-9]|$)" /root/lab-answers/5 && grep -q crontab /root/lab-answers/5'
