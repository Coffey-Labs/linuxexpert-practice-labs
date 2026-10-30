! pkg_installed tree || refuse "tree is installed; remove it first (the lab grades installing and removing it)"
if is_rhel; then
	state_set history "$(dnf history list 2>/dev/null | awk -F'|' 'NR > 2 {gsub(/ /, "", $1); print $1; exit}')"
	pkg_installed python3-dnf-plugin-versionlock && state_set had-versionlock 1
	if dnf versionlock list 2>/dev/null | grep -q '^bash-'; then refuse "bash is already version-locked; run dnf versionlock delete bash first"; fi
else
	state_set history "$(cat /var/log/apt/history.log 2>/dev/null | wc -l)"
	! apt-mark showhold | grep -qx bash || refuse "bash is already on hold; run apt-mark unhold bash first"
fi
true
