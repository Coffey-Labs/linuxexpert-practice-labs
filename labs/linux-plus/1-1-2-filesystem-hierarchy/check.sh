# Answers as plain lines, lowercase, without spaces or a trailing slash.
lines() { tr 'A-Z' 'a-z' <"/root/lab-answers/$1" 2>/dev/null | tr -d ' \t\r' | sed 's|\(.\)/*$|\1|' | grep .; }
links=$(for d in /bin /sbin /lib /tmp; do [ -L "$d" ] && echo "$d"; done)
# The two biggest directories under /var: the answer may change a little.
biggest=$(du -s /var/* 2>/dev/null | sort -n | tail -n2 | awk '{print $2}')
real=$(findmnt --real -rn -o TARGET)
if is_rhel; then owner=$(rpm -qf --qf '%{NAME}\n' /usr/bin/ls | head -n1); else owner=$(dpkg -S /usr/bin/ls | head -n1 | cut -d: -f1); fi

task 1 "The symbolic links among /bin /sbin /lib /tmp"
need "/root/lab-answers/1 lists the links: $(echo $links)" '
	[ "$(lines 1 | sed "s|^\([^/]\)|/\1|" | sort -u)" = "$(sort -u <<<"$links")" ]'

task 2 "The biggest directory under /var"
need "/root/lab-answers/2 names the biggest directory under /var" '
	a=$(lines 2 | head -n1); a=/var/${a#/var/}; grep -qxF "$a" <<<"$biggest"'

task 3 "The mount points of the real filesystems"
need "/root/lab-answers/3 lists every real filesystem's mount point" '
	[ -n "$(lines 3)" ] && while read -r m; do lines 3 | grep -qxF "$m" || exit 1; done <<<"$real"'
need "/root/lab-answers/3 lists no virtual filesystems" '
	lines 3 | while read -r m; do grep -qxF "$m" <<<"$real" || exit 1; done'

task 4 "The package that owns /usr/bin/ls"
need "/root/lab-answers/4 names the package $owner" '
	a=$(lines 4 | head -n1); a=${a%%:*}; [ "$a" = "$owner" ] || [[ $a == "$owner"-[0-9]* ]] || [[ $a == "$owner"_[0-9]* ]]'
need "/etc/mynote is removed again" '[ ! -e /etc/mynote ]'
