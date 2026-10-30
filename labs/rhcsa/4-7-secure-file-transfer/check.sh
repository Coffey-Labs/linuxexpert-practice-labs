A=/home/alice B=/home/bob
# Task 1: every file of the project in bob's copy, with its mode, and its
# date as it was or as alice's copy has it now.
proj_copied() {
	local f mode mt sum
	[ -s "$LAB_STATE/files" ] || return 1
	while read -r f mode mt sum; do
		[ -f "$B/proj/$f" ] || return 1
		[ "$(stat -c %a "$B/proj/$f")" = "$mode" ] || return 1
		t=$(stat -c %Y "$B/proj/$f")
		[ "$t" = "$mt" ] || [ "$t" = "$(stat -c %Y "$A/proj/$f" 2>/dev/null)" ] || return 1
	done <"$LAB_STATE/files"
}
proj_changed() {
	local f mode mt sum
	while read -r f mode mt sum; do
		[ "$(sha256sum <"$A/proj/$f" 2>/dev/null | cut -d" " -f1)" != "$sum" ] && return 0
	done <"$LAB_STATE/files"
	return 1
}

task 1 "~/proj copied to bob@peer:proj with modes and times"
need "$B/proj exists and is bob's" '[ -d $B/proj ] && [ "$(stat -c %U $B/proj)" = bob ]'
need "each file has its mode and modification time" proj_copied

task 2 "/etc/os-release fetched into ~/got"
need "$A/got/os-release exists" '[ -f $A/got/os-release ]'
need "it's identical to the peer's /etc/os-release" 'cmp -s $A/got/os-release /etc/os-release'

task 3 "~/proj/ synced to bob@peer:backup/ with rsync, after a change"
need "$B/backup holds the files of proj, not a proj directory" '[ -f $B/backup/notes.txt ] && [ ! -e $B/backup/proj ]'
need "a file in ~/proj was changed" proj_changed
need "$B/backup matches ~/proj, with the change" 'diff -r $A/proj $B/backup'

task 4 "report.txt uploaded to /tmp with sftp and downloaded as report-back.txt"
need "/tmp/report.txt was uploaded as bob" '[ -f /tmp/report.txt ] && [ "$(stat -c %U /tmp/report.txt)" = bob ]'
need "/tmp/report.txt is identical to ~/report.txt" 'cmp -s /tmp/report.txt $A/report.txt'
need "$A/report-back.txt is identical too" 'cmp -s $A/report-back.txt $A/report.txt'
