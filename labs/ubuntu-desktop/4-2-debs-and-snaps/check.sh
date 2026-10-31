firefox_kind() {
	if snap list firefox >/dev/null 2>&1; then echo snap
	elif dpkg-query -W -f '${db:Status-Abbrev} ${Version}' firefox 2>/dev/null | grep -Eq '^ii .*' &&
		! dpkg-query -W -f '${Version}' firefox | grep -q snap; then echo deb
	else echo none
	fi
}
snap_htoprc_tree() {
	local f
	for f in /root/snap/htop/*/.config/htop/htoprc /home/*/snap/htop/*/.config/htop/htoprc; do
		[ -f "$f" ] && grep -Eq '(^|\.)tree_view=1' "$f" && return 0
	done
	return 1
}
new_snapshot() {
	snap saved htop 2>/dev/null | awk 'NR > 1 && $2 == "htop" {print $1}' | grep -vxF -f "$LAB_STATE/old-snapshots" | grep -q .
}

task 1 "Whether Firefox is a deb or a snap"
need "/root/lab-answers/1 says $(firefox_kind)" 'a=$(answer 1); e=$(firefox_kind); [ "$a" = "$e" ] || { [ "$e" = none ] && [[ $a =~ ^(neither|not.installed|no)$ ]]; }'

task 2 "htop replaced by its snap, Tree view setting kept"
need "the htop deb is gone (dpkg -l htop has no ii line)" '[ "$(dpkg-query -W -f "\${db:Status-Abbrev}" htop 2>/dev/null | cut -c1-2)" != ii ]'
need "the htop snap is installed" 'snap list htop'
need "the snap's htoprc has Tree view on (tree_view=1)" snap_htoprc_tree

task 3 "htop snap removed and its data restored"
need "snap saved lists an htop snapshot made during the lab" new_snapshot
need "the htop snap is installed again" 'snap list htop'
need "its htoprc is back, with Tree view on" snap_htoprc_tree
