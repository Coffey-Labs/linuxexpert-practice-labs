etc_ok() {
	local f n=0 now; now=$(date +%s)
	[ -s /root/lab-answers/2-etc ] || return 1
	while read -r f; do
		[ -n "$f" ] || continue
		case $f in /etc/*) ;; *) return 1 ;; esac
		[ -e "$f" ] || continue
		# Changed within a day of the answer being written (with an hour to spare).
		[ $(( $(stat -c %Y /root/lab-answers/2-etc) - $(stat -c %Y "$f") )) -le 90000 ] || return 1
		n=$((n + 1))
	done </root/lab-answers/2-etc
	[ "$n" -gt 0 ]
}
usr_ok() {
	local want got
	want=$(find /usr -xdev -type f -size +10M 2>/dev/null | sort)
	got=$(grep -o '/usr/[^[:space:]]*' /root/lab-answers/2-usr 2>/dev/null | sort -u)
	[ -n "$want" ] && [ -z "$(comm -23 <(printf '%s\n' "$want") <(printf '%s\n' "$got"))" ] || return 1
	# and nothing much under 10 MiB.
	local f
	for f in $got; do [ ! -f "$f" ] || [ "$(stat -c %s "$f")" -ge 10000000 ] || return 1; done
}
compress_ok() {
	local d=/root/compress g b x
	g=$(ls "$d"/*.gz 2>/dev/null | head -n1); b=$(ls "$d"/*.bz2 2>/dev/null | head -n1); x=$(ls "$d"/*.xz 2>/dev/null | head -n1)
	[ -n "$g" ] && [ -n "$b" ] && [ -n "$x" ] || return 1
	[ -n "$(gzip -dc "$g" | head -c1)" ] || return 1
	cmp -s <(gzip -dc "$g") <(bzip2 -dc "$b") && cmp -s <(gzip -dc "$g") <(xz -dc "$x")
}

task 1 "/root/practice/a, b and c, with a file in each"
need "/root/practice/a, b and c each hold a file" 'for x in a b c; do [ -n "$(find /root/practice/$x -mindepth 1 -maxdepth 1 -type f)" ] || exit 1; done'

task 2 "Recent files under /etc and big files under /usr listed"
need "/root/lab-answers/2-etc lists files under /etc changed in the day before" etc_ok
need "/root/lab-answers/2-usr lists every file over 10 MiB under /usr" usr_ok

task 3 "/etc archived with xz; etc/hostname extracted into /tmp"
need "/root/etc.tar.xz is an xz-compressed tar of /etc" 'tar -tJf /root/etc.tar.xz | grep -qx "etc/passwd"'
need "/tmp/etc/hostname was extracted from it" '[ -f /tmp/etc/hostname ] && tar -xJOf /root/etc.tar.xz etc/hostname | cmp -s - /tmp/etc/hostname'

task 4 "One log compressed three ways"
need "/root/compress holds .gz, .bz2 and .xz copies of the same file" compress_ok

task 5 "The first megabyte of /dev/loop40 copied with dd"
need "/root/first-mb.img is 1 MiB" '[ "$(stat -c %s /root/first-mb.img)" = 1048576 ]'
need "it matches the start of /dev/loop40" 'head -c 1048576 /dev/loop40 | cmp -s - /root/first-mb.img'
