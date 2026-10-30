D=/root/links
current_ok() {
	[ -L $D/releases/current ] && [ "$(readlink -f $D/releases/current)" = "$(readlink -f $D/releases/1.1)" ] && [ -d $D/releases/1.1 ]
}
chain_ok() {
	local first last
	first=$(grep -m1 . /root/lab-answers/5 2>/dev/null | awk '{print $NF}')
	last=$(grep . /root/lab-answers/5 2>/dev/null | tail -n1 | awk '{print $NF}')
	[ "$first" = /usr/bin/editor ] && [ -e "$last" ] && [ ! -L "$last" ] &&
		[ "$(readlink -f "$last")" = "$(readlink -f /usr/bin/editor)" ] &&
		grep -q /etc/alternatives/editor /root/lab-answers/5
}

task 1 "A hard link and a symlink, the original deleted"
need "original.txt is deleted" '[ ! -e $D/original.txt ] && [ ! -L $D/original.txt ]'
need "hard.txt still has the text" '[ -f $D/hard.txt ] && [ ! -L $D/hard.txt ] && [ -s $D/hard.txt ]'
need "soft.txt is a symlink to original.txt, now dangling" '[ -L $D/soft.txt ] && [ "$(basename "$(readlink $D/soft.txt)")" = original.txt ] && [ ! -e $D/soft.txt ]'

task 2 "The two hard-link errors"
need "/root/lab-answers/2 has the cross-device error" 'grep -qi "cross-device" /root/lab-answers/2'
need "and the one about directories" 'grep -qi "directory" /root/lab-answers/2'

task 3 "Link counts of a directory"
need "parent has two subdirectories" '[ "$(find $D/parent -mindepth 1 -maxdepth 1 -type d | wc -l)" -eq 2 ]'
need "/root/lab-answers/3 has 2, then 4" '[ "$(sed -n 1p /root/lab-answers/3 | tr -dc 0-9)" = 2 ] && [ "$(sed -n 2p /root/lab-answers/3 | tr -dc 0-9)" = 4 ]'

task 4 "current switched to 1.1 with ln -sf, then ln -sfn"
need "releases/1.0 and releases/1.1 are directories" '[ -d $D/releases/1.0 ] && [ ! -L $D/releases/1.0 ] && [ -d $D/releases/1.1 ] && [ ! -L $D/releases/1.1 ]'
need "ln -sf left a 1.1 link inside releases/1.0" '[ -L $D/releases/1.0/1.1 ]'
need "current points to 1.1" current_ok

task 5 "/usr/bin/editor followed to the real program" debian
need "/root/lab-answers/5 starts at /usr/bin/editor, goes through /etc/alternatives/editor and ends at the real program" chain_ok
