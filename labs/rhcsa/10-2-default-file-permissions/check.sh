# A login shell's umask, and the mode of something it creates.
um() { runuser -l "$1" -c umask 2>/dev/null; }
made() {
	local u=$1 kind=$2 f m
	f=$(runuser -l "$u" -c 'd=$(mktemp -d); echo $d' 2>/dev/null)
	[ -n "$f" ] || return 1
	if [ "$kind" = file ]; then runuser -l "$u" -c "touch $f/t"; m=$(stat -c %A "$f/t"); else runuser -l "$u" -c "mkdir $f/d"; m=$(stat -c %A "$f/d"); fi
	rm -rf "$f"
	echo "$m"
}

task 1 "alice's new files are rw------- (umask 0077)"
need "su - alice -c umask prints 0077" '[ "$(um alice)" = 0077 ]'
need "a file alice creates is -rw-------" '[ "$(made alice file)" = -rw------- ]'
need "the umask is set in one of alice's own files" 'grep -Eqs "^[[:space:]]*umask[[:space:]]+0?077" /home/alice/.bashrc /home/alice/.bash_profile /home/alice/.profile'

task 2 "Everyone's new directories are rwxr-x--- (umask 0027)"
need "su - bob -c umask prints 0027" '[ "$(um bob)" = 0027 ]'
need "a directory bob creates is drwxr-x---" '[ "$(made bob dir)" = drwxr-x--- ]'
need "the umask is in a file in /etc/profile.d/" 'grep -Eqs "^[[:space:]]*umask[[:space:]]+0?027" /etc/profile.d/*.sh'
need "alice still has 0077" '[ "$(um alice)" = 0077 ]'
