apt-mark showhold | sort >"$LAB_STATE/holds-before"
snap list 2>/dev/null | awk 'NR > 1 {print $1}' >"$LAB_STATE/snaps-before"
state_set debs "$(dpkg -l | grep -c '^ii')"
