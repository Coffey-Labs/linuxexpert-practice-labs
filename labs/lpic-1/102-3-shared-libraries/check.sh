# The package names that own a library file, given as it appears in ldd.
owners() {
	local p=$1 c
	for c in "$p" "$(readlink -f "$p")" "/usr${p#/usr}" "${p#/usr}"; do
		[ -n "$c" ] || continue
		if is_rhel; then rpm -qf --qf '%{NAME}\n' "$c" 2>/dev/null | grep -v 'not owned'
		else dpkg -S "$c" 2>/dev/null | cut -d: -f1 | tr ',' '\n' | tr -d ' '; fi
	done | sort -u
}
# lib_line PROGRAM: answer 1 has a line for it with a library it uses and
# the package that owns that library.
lib_line() {
	local prog=$1 line lib pkg path o
	while read -r line; do
		set -- $line
		[ "$(basename "${1:-}")" = "$prog" ] || continue
		lib=$(basename "${2:-}") pkg=${3:-}
		pkg=${pkg%%:*}
		[ -n "$lib" ] && [ -n "$pkg" ] || continue
		path=$(ldd "/usr/bin/$prog" | awk -v l="$lib" '$1 == l && $3 ~ /^\// {print $3} $1 ~ "/"l"$" {print $1}' | head -n1)
		[ -n "$path" ] || continue
		for o in $(owners "$path"); do
			case $pkg in "$o" | "$o"-[0-9]*) return 0 ;; esac
		done
	done </root/lab-answers/1
	return 1
}
zlib_paths() { ldconfig -p | awk '$1 == "libz.so.1" {print $NF; exit}'; }

task 1 "A library of ls, ssh and bash traced to its package"
need "/root/lab-answers/1 exists" '[ -s /root/lab-answers/1 ]'
need "a line for ls names one of its libraries and the package that installed it" 'lib_line ls'
need "a line for ssh names one of its libraries and the package that installed it" 'lib_line ssh'
need "a line for bash names one of its libraries and the package that installed it" 'lib_line bash'

task 2 "zlib's soname and real name"
need "line 1 of /root/lab-answers/2 is zlib's soname" '[ "$(sed -n 1p /root/lab-answers/2 | tr -d "[:space:]" | xargs -r basename)" = libz.so.1 ]'
need "line 2 is the real name the soname points to" '[ "$(sed -n 2p /root/lab-answers/2 | tr -d "[:space:]" | xargs -r basename)" = "$(basename "$(readlink -f "$(zlib_paths)")")" ]'

task 3 "/opt/test/lib added to the linker's path and taken out again" self
