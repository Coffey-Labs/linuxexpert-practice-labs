# same_meta A B: same type, mode, owner, group and modification time.
same_meta() { [ "$(stat -c '%F %a %U %G %Y' "$1" 2>/dev/null)" = "$(stat -c '%F %a %U %G %Y' "$2" 2>/dev/null)" ]; }
skel_copied() {
	local f
	while read -r f; do
		same_meta "/etc/skel/$f" "/root/skel-backup/$f" || return 1
	done < <(cd /etc/skel && find . -mindepth 1)
}

task 1 "/data/web/html and /data/web/logs"
need "/data/web/html is a directory" '[ -d /data/web/html ]'
need "/data/web/logs is a directory" '[ -d /data/web/logs ]'

task 2 "/etc/skel copied to /root/skel-backup with everything kept"
need "/root/skel-backup is a directory" '[ -d /root/skel-backup ]'
need "it holds the hidden files, such as .bashrc" '[ -f /root/skel-backup/.bashrc ]'
need "every file has the same mode, owner and date as in /etc/skel" skel_copied

task 3 "Hard link /root/hosts-hard, symbolic link /root/hosts-soft"
need "/root/hosts-hard has the same inode as /etc/hosts" '[ ! -L /root/hosts-hard ] && [ /root/hosts-hard -ef /etc/hosts ]'
need "/root/hosts-soft is a symbolic link" '[ -L /root/hosts-soft ]'
need "/root/hosts-soft points to /etc/hosts" '[ "$(readlink -f /root/hosts-soft)" = /etc/hosts ]'

task 4 "Authorized users only at the end of /etc/motd"
need "the last line of /etc/motd is Authorized users only" '[ "$(tail -n1 /etc/motd)" = "Authorized users only" ]'
