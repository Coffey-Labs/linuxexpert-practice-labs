line() { sed -n "${2}p" "/root/lab-answers/$1" 2>/dev/null | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'; }
csv=/usr/share/distro-info/ubuntu.csv
. /etc/os-release
eol_of() { awk -F, -v s="$1" '$3 == s {print $6}' "$csv"; }
# month LINE: YYYY-MM from an answer such as 2029-05-31 or May 2029.
month() {
	local a=$1
	if [[ $a =~ ^([0-9]{4}-[0-9]{2}) ]]; then printf '%s' "${BASH_REMATCH[1]}"; return; fi
	date -d "1 $a" +%Y-%m 2>/dev/null
}
# The supported releases as "VERSION" or "VERSION LTS", sorted.
expected() {
	local skip=${1:-}
	ubuntu-distro-info --supported --fullname 2>/dev/null | while read -r _ ver rest; do
		[ -n "$skip" ] && [ "$(ubuntu-distro-info --series="$skip" -r 2>/dev/null | cut -d' ' -f1)" = "$ver" ] && continue
		case $rest in LTS*) echo "$ver LTS" ;; *) echo "$ver" ;; esac
	done | sort
}
given() {
	grep -v '^[[:space:]]*$' /root/lab-answers/3 2>/dev/null | while read -r l; do
		v=$(grep -Eo '[0-9]{2}\.[0-9]{2}' <<<"$l" | head -n1)
		[ -n "$v" ] || continue
		if grep -qi 'lts' <<<"$l"; then echo "$v LTS"; else echo "$v"; fi
	done | sort -u
}

task 1 "This system's point release and code name"
need "line 1 of /root/lab-answers/1 is the point release ($VERSION_ID.x)" '[ "$(line 1 1)" = "${VERSION%% *}" ]'
need "line 2 is the code name" 'line 1 2 | tr A-Z a-z | grep -qw "$VERSION_CODENAME"'

task 2 "End of standard support: this release and the latest LTS"
need "line 1 of /root/lab-answers/2 is this release's end of support" '[ "$(month "$(line 2 1)")" = "$(eol_of "$VERSION_CODENAME" | cut -c1-7)" ]'
need "line 2 is the latest LTS's end of support" '[ "$(month "$(line 2 2)")" = "$(eol_of "$(ubuntu-distro-info --lts)" | cut -c1-7)" ]'

task 3 "Every supported release, LTS ones marked"
need "/root/lab-answers/3 lists exactly the supported releases, with LTS marked and the development release left out" '[ "$(given)" = "$(expected "$(ubuntu-distro-info --devel 2>/dev/null)")" ]'
