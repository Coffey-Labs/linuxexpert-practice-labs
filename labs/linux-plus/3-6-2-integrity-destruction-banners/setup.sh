F=/usr/share/zoneinfo/Pacific/Pitcairn
[ -f $F ] || refuse "$F is missing; this lab changes it on purpose"
[ -e /etc/ssh/lab-new-file ] && refuse "/etc/ssh/lab-new-file already exists; remove it and start again"
# Task 1: a changed file of a package (a time zone nobody here uses).
cp -a $F "$LAB_STATE/tzfile"
printf 'le-lab\n' >>$F
# Task 3: the SSH configuration and the banner file, for reset.
tar -C /etc -cf "$LAB_STATE/ssh.tar" ssh
[ -f /etc/issue.net ] && cp -a /etc/issue.net "$LAB_STATE/issue.net"
# Task 4: a disk full of old data.
d=$(disk_add 0 64M)
yes "customer record 0042: Jane Example, 555-0100" | head -c 64M >"$d" || true
sync
true
