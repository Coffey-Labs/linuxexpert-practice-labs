. /etc/os-release
dpkg_did() {
	local since; since=$(state_get since)
	awk -v s="$since" -v a="$1" -v p="$2" \
		'($1 " " $2) >= s && $3 == a && ($4 == p || index($4, p ":") == 1) {ok = 1} END {exit !ok}' /var/log/dpkg.log 2>/dev/null
}
rdeps() { apt-cache rdepends --installed libnl-3-200 2>/dev/null | sed -n '/^Reverse Depends:/,$p' | sed '1d; s/^[[:space:]|]*//; s/:.*//' | sort -u; }

task 1 "unattended-upgrades allows $VERSION_CODENAME-updates"
need "unattended-upgrade --dry-run lists a=$VERSION_CODENAME-updates in its allowed origins" 'timeout 120 unattended-upgrade --dry-run --debug 2>&1 | grep "Allowed origins" | grep -q "a=$VERSION_CODENAME-updates"'

task 2 "nano purged, then installed again"
need "dpkg's log shows nano purged" 'dpkg_did purge nano'
need "nano is installed again" 'pkg_installed nano'
need "/etc/nanorc is back as the package ships it" '[ -f /etc/nanorc ] && ! grep -q "^# le-lab:" /etc/nanorc'

task 3 "aptitude installed, dependent of libnl-3-200 found"
need "aptitude is installed" 'command -v aptitude'
need "/root/lab-answers/3 names an installed package that depends on libnl-3-200" 'a=$(answer 3); [ -n "$a" ] && rdeps | grep -qx -- "$a"'
