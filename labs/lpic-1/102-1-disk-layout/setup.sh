disk_add 0 2G >/dev/null
swapon --show=NAME --noheadings >"$LAB_STATE/old-swaps"
