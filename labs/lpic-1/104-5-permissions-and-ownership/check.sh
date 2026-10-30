mode() { stat -c %a "$1" 2>/dev/null; }
readable_file() {
	local f
	for f in /srv/test/*; do
		[ -f "$f" ] && runuser -u tess -- cat "$f" >/dev/null 2>&1 && return 0
	done
	return 1
}
# Files in /srv/web from anna and from ben, all in group web and
# group-writable.
web_files() {
	local f a=0 b=0
	for f in /srv/web/*; do
		[ -f "$f" ] || continue
		[ "$(stat -c %G "$f")" = web ] || return 1
		case $(stat -c %U "$f") in anna) a=1 ;; ben) b=1 ;; esac
		[ $(( $(mode "$f") / 10 % 10 & 2 )) -ne 0 ] || return 1
	done
	[ $a = 1 ] && [ $b = 1 ]
}
in_web() { id -nG "$1" 2>/dev/null | grep -qw web; }
setid_ok() {
	local f n=0 all
	for f in $(grep -oE '/[^[:space:]]+' /root/lab-answers/5 2>/dev/null); do
		[ -u "$f" ] || [ -g "$f" ] || return 1
		n=$((n + 1))
	done
	grep -Eq '/bin/passwd([[:space:]]|$)' /root/lab-answers/5 || return 1
	all=$(find / -xdev -type f -perm /6000 2>/dev/null | wc -l)
	[ "$n" -ge $((all * 8 / 10)) ]
}

task 1 "report.txt: owner reads and writes, group reads, others nothing"
need "/root/perm/report.txt has mode 640" '[ "$(mode /root/perm/report.txt)" = 640 ]'
need "/root/lab-answers/1 has the mode" '[ "$(answer 1 | sed "s/^0*//")" = 640 ]'

task 2 "/srv/test: mode 711, its file readable by path only"
need "/srv/test has mode 711" '[ "$(mode /srv/test)" = 711 ]'
need "tess can cat a file in it by its full path" readable_file
need "tess can't list it" '! runuser -u tess -- ls /srv/test'

task 3 "Files and directories made under umask 077 and 033"
need "f077 has mode 600 and d077 mode 700" '[ "$(mode /root/perm/f077)" = 600 ] && [ "$(mode /root/perm/d077)" = 700 ]'
need "f033 has mode 644 and d033 mode 744" '[ "$(mode /root/perm/f033)" = 644 ] && [ "$(mode /root/perm/d033)" = 744 ]'

task 4 "/srv/web shared by anna and ben, mode 3770"
need "group web has anna and ben" 'in_web anna && in_web ben'
need "/srv/web belongs to group web" '[ "$(stat -c %G /srv/web)" = web ]'
need "/srv/web has mode 3770 (setgid and sticky)" '[ "$(mode /srv/web)" = 3770 ]'
need "anna and ben each have a file in it, in group web and group-writable" web_files

task 5 "Setuid and setgid programs listed"
need "/root/lab-answers/5 lists the setuid and setgid programs, passwd among them" setid_ok
