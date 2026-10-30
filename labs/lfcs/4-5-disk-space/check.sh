# Line LINE of answer N as a full path; relative answers are under BASE.
ans_path() { # N LINE BASE
	local a
	a=$(sed -n "$2p" "/root/lab-answers/$1" 2>/dev/null | sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s|/*$||')
	[ -n "$a" ] || return 0
	case $a in /*) ;; *) a=$3/$a ;; esac
	printf '%s\n' "$a"
}
big_dir() { du -xk --max-depth=1 /mnt/spare 2>/dev/null | awk '$2 != "/mnt/spare"' | sort -n | tail -n1 | cut -f2; }
big_file() { find /mnt/spare -xdev -type f -printf '%s %p\n' 2>/dev/null | sort -n | tail -n1 | cut -d' ' -f2-; }
# The directory under /mnt/small holding the most entries.
inode_dir() { find /mnt/small -xdev -mindepth 1 -not -path '/mnt/small/lost+found*' | sed 's|/[^/]*$||' | sort | uniq -c | sort -n | tail -n1 | awk '{print $2}'; }

df_du_agree() {
	local used du
	used=$(df -k --output=used /mnt/spare | tail -n1 | tr -d ' ')
	du=$(du -sxk /mnt/spare | cut -f1)
	[ $((used - du)) -lt 51200 ]
}

# SystemMaxUse in effect, in bytes, is set and at most 200M.
journal_max_ok() {
	local v
	v=$(systemd-analyze cat-config systemd/journald.conf 2>/dev/null | grep -E '^[[:space:]]*SystemMaxUse=' | tail -n1 | cut -d= -f2 | tr -d ' ')
	v=${v%B}
	[ -n "$v" ] && v=$(numfmt --from=iec "$v" 2>/dev/null) && [ "$v" -gt 0 ] && [ "$v" -le 209715200 ]
}
journal_kb() { du -sk /var/log/journal /run/log/journal 2>/dev/null | awk '{s += $1} END {print s + 0}'; }

task 1 "Biggest directory and file on /mnt/spare found"
need "/mnt/spare is mounted" 'findmnt /mnt/spare'
need "line 1 of /root/lab-answers/1 is the biggest directory" '[ "$(ans_path 1 1 /mnt/spare)" = "$(big_dir)" ]'
need "line 2 is the biggest file" '[ "$(ans_path 1 2 /mnt/spare)" = "$(big_file)" ]'

task 2 "Space held by a deleted file freed"
need "/root/lab-answers/2 names the program holding it" 'answer 2 | grep -q applog'
need "no deleted file on /mnt/spare is still open" '! find /proc/[0-9]*/fd -lname "/mnt/spare/*(deleted)" 2>/dev/null | grep -q .'
need "df and du agree about /mnt/spare" df_du_agree

task 3 "Journal limited to 200 MB"
need "journald's configuration sets SystemMaxUse to 200M or less" journal_max_ok
need "the journal uses 200M or less now" '[ "$(journal_kb)" -le 204800 ]'

task 4 "Inodes of /mnt/small exhausted, directory found"
need "/mnt/small is mounted" 'findmnt /mnt/small'
need "df -i shows /mnt/small at 100%" '[ "$(df --output=ipcent /mnt/small | tail -n1 | tr -d " %")" = 100 ]'
need "df -h still shows free space on it" '[ "$(df -k --output=avail /mnt/small | tail -n1)" -gt 1024 ]'
need "/root/lab-answers/4 names the directory with the most files" '[ "$(ans_path 4 1 /mnt/small)" = "$(inode_dir)" ]'

task 5 "/var/log/myapp/*.log rotated daily, 5 compressed copies"
need "/etc/logrotate.d/myapp exists" '[ -f /etc/logrotate.d/myapp ]'
need "logrotate -d /etc/logrotate.d/myapp reports no errors" 'out=$(logrotate -d /etc/logrotate.d/myapp 2>&1) && ! printf "%s\n" "$out" | grep -qi error'
need "it rotates /var/log/myapp/*.log daily, keeping 5" 'logrotate -d /etc/logrotate.d/myapp 2>&1 | grep -F "/var/log/myapp/*.log" | grep "after 1 days" | grep -qF "(5 rotations)"'
need "it compresses the old copies" 'grep -Eq "^[[:space:]]*compress([[:space:]]|$)" /etc/logrotate.d/myapp'
