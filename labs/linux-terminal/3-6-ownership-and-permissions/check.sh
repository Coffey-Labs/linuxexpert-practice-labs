H=$(state_get home)
F=/srv/finance
# shared_dir_works: ana's new file gets group finance, ben can create one
# too but can't remove ana's.
shared_dir_works() {
	local a=$F/.le-check-ana-$$ b=$F/.le-check-ben-$$ r=1
	runuser -u ana -- touch "$a" 2>/dev/null && [ "$(stat -c %G "$a")" = finance ] &&
		runuser -u ben -- touch "$b" 2>/dev/null &&
		! runuser -u ben -- rm -f "$a" 2>/dev/null && [ -e "$a" ] && r=0
	rm -f "$a" "$b"
	return $r
}

task 1 "/srv/finance: root:finance, mode 3770, shared by ana and ben"
need "group finance exists" 'getent group finance'
need "ana and ben are members of finance" 'id -nG ana | grep -qw finance && id -nG ben | grep -qw finance'
need "$F is a directory owned by root and group finance" '[ -d $F ] && [ "$(stat -c "%U %G" $F)" = "root finance" ]'
need "ls -ld $F shows drwxrws--T (mode 3770)" '[ "$(stat -c %a $F)" = 3770 ]'
need "a member's new file belongs to finance, and the other member can't delete it" shared_dir_works

task 2 "~/private is 700 and ~/private/notes.txt is 600, owned by student"
need "$H/private is a directory with mode 700" '[ -d "$H/private" ] && [ "$(stat -c %a "$H/private")" = 700 ]'
need "$H/private/notes.txt is a file with mode 600" '[ -f "$H/private/notes.txt" ] && [ "$(stat -c %a "$H/private/notes.txt")" = 600 ]'
need "both belong to student" '[ "$(stat -c %U "$H/private" "$H/private/notes.txt" | sort -u)" = student ]'

task 3 "The setuid program for changing passwords in /root/lab-answers/3"
need "/root/lab-answers/3 holds /usr/bin/passwd" '[ "$(answer 3)" = /usr/bin/passwd ]'
