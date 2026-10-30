pkg_installed mariadb && refuse "mariadb is already installed; remove it (dnf remove mariadb) and start again"
say "${C_DIM}Checking for updates...${C_0}"
rc=0
dnf -q check-update >/dev/null 2>&1 || rc=$?
[ "$rc" = 0 ] || [ "$rc" = 100 ] || refuse "dnf check-update failed; the lab needs working repositories"
if [ "$rc" = 0 ]; then
	# Nothing to update: put an older version of a small package in place.
	for p in tzdata tar vim-minimal; do
		if dnf -y -q downgrade "$p" >/dev/null 2>&1; then
			state_set downgraded "$p"
			break
		fi
	done
	[ -n "$(state_get downgraded)" ] || refuse "the system is up to date and no package could be downgraded to leave an update to apply"
fi
state_set history "$(dnf -q history list 2>/dev/null | awk '$1 ~ /^[0-9]+$/ {print $1; exit}')"
