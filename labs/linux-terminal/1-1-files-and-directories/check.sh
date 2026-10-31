H=$(state_get home)
L=$H/lab
# skel_kept: every file under /etc/skel is in ~/lab/skel, same type and
# modification time.
skel_kept() {
	local f
	while read -r f; do
		[ "$(stat -c '%F %Y' "/etc/skel/$f")" = "$(stat -c '%F %Y' "$L/skel/$f" 2>/dev/null)" ] || return 1
	done < <(cd /etc/skel && find . -mindepth 1)
}

task 1 "~/lab/app/config, and /etc/skel copied to ~/lab/skel with hidden files and dates"
need "$L/app/config is a directory" '[ -d "$L/app/config" ]'
need "$L/skel holds the hidden files, such as .bashrc" '[ -f "$L/skel/.bashrc" ]'
need "every file in ~/lab/skel has the same date as in /etc/skel" skel_kept

task 2 "notes.hard and notes.link made, then notes.txt renamed to notes.old"
need "$L/notes.old contains hello" 'grep -qw hello "$L/notes.old"'
need "$L/notes.txt is gone (renamed)" '[ ! -e "$L/notes.txt" ] && [ ! -L "$L/notes.txt" ]'
need "notes.hard is a hard link to notes.old (same inode)" '[ ! -L "$L/notes.hard" ] && [ "$L/notes.hard" -ef "$L/notes.old" ]'
need "stat -c %h notes.old prints 2" '[ "$(stat -c %h "$L/notes.old")" = 2 ]'
need "notes.link is a symbolic link to notes.txt" '[ -L "$L/notes.link" ] && [ "$(basename "$(readlink "$L/notes.link")")" = notes.txt ]'
need "notes.link is broken now" '[ ! -e "$L/notes.link" ]'

task 3 "logs and data removed: only config left in ~/lab/app"
need "$L/app exists" '[ -d "$L/app" ]'
need "$L/app/logs is gone" '[ ! -e "$L/app/logs" ]'
need "$L/app/data is gone" '[ ! -e "$L/app/data" ]'
need "ls ~/lab/app lists only config" '[ "$(ls -A "$L/app")" = config ]'
