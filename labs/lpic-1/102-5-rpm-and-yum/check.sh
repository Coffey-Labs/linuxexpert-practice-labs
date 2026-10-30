verify_listed() {
	local f n=0
	for f in $(rpm -V openssh-server 2>/dev/null | awk '{print $NF}'); do
		grep -qE "(^|[[:space:]])$f([[:space:]]|$)" /root/lab-answers/1 || return 1
		n=$((n + 1))
	done
	[ "$n" -gt 0 ]
}
# Transactions since setup: one installed bind-utils, a later one (an
# undo) removed it.
undone() {
	local start id inst=''
	start=$(state_get history); start=${start:-0}
	for id in $(dnf -q history list 2>/dev/null | awk -v s="$start" '$1 ~ /^[0-9]+$/ && $1 > s {print $1}' | sort -n); do
		info=$(LC_ALL=C dnf -q history info "$id" 2>/dev/null)
		if [ -z "$inst" ] && printf '%s\n' "$info" | grep -Eq '^[[:space:]]+Install[[:space:]]+bind-utils-'; then
			inst=$id
		elif [ -n "$inst" ] && printf '%s\n' "$info" | grep -Eq '^[[:space:]]+(Removed|Erase|Remove)[[:space:]]+bind-utils-' &&
			printf '%s\n' "$info" | grep -Eq '^Command Line[[:space:]]*:.*(undo|rollback)'; then
			return 0
		fi
	done
	return 1
}

task 1 "Owner of sshd_config found and verified"
need "line 1 of /root/lab-answers/1 is the package that owns /etc/ssh/sshd_config" '[ "$(sed -n 1p /root/lab-answers/1 | tr -d "[:space:]")" = "$(rpm -qf --qf "%{NAME}" /etc/ssh/sshd_config)" ]'
need "every file rpm -V reports is listed below it" verify_listed

task 2 "tree downloaded, queried and one file extracted"
need "/root/rpms holds the tree package" 'for f in /root/rpms/tree-*.rpm; do [ "$(rpm -qp --qf "%{NAME}" "$f" 2>/dev/null)" = tree ] && exit 0; done; exit 1'
need "/root/rpms/usr/bin/tree was extracted from it" '[ -x /root/rpms/usr/bin/tree ] && /root/rpms/usr/bin/tree --version'

task 3 "dig's package found, installed, and the install undone"
need "/root/lab-answers/3 names the package with dig" '[ "$(answer 3)" = bind-utils ]'
need "the DNF history shows bind-utils installed, then the install undone" undone
need "bind-utils isn't installed any more" '! rpm -q bind-utils'
