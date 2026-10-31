# Answer lines, lowercase.
ans() { tr 'A-Z' 'a-z' <"/root/lab-answers/$1" 2>/dev/null; }
LR=$(grep -lE '/var/log/webapp/' /etc/logrotate.d/* 2>/dev/null | head -n1)
W=/var/log/webapp

task 1 "alice's last three sudo commands in /root/lab-answers/1"
need "/root/lab-answers/1 has cat /etc/hostname" 'ans 1 | grep -qF "cat /etc/hostname"'
need "/root/lab-answers/1 has du -sh /var/log" 'ans 1 | grep -qF "du -sh /var/log"'
need "/root/lab-answers/1 has tail -n 5 /var/log/dpkg.log" 'ans 1 | grep -qF "tail -n 5 /var/log/dpkg.log"'
need "/root/lab-answers/1 has only the last three (not ls /etc/apt, the one before)" '! ans 1 | grep -qF "ls /etc/apt"'

task 2 "logrotate rotates /var/log/webapp/access.log weekly, 4 compressed, create 640 root adm"
need "a file in /etc/logrotate.d names /var/log/webapp/access.log" '[ -n "$LR" ]'
need "logrotate -d shows it rotated weekly, keeping 4" 'logrotate -d /etc/logrotate.conf 2>&1 | grep -E "^rotating pattern: .*/var/log/webapp/" | grep -q "weekly (4 rotations)"'
need "logrotate -d reports no errors for it" '! logrotate -d "$LR" 2>&1 | grep -qi "^error"'
need "$LR compresses old copies" 'grep -Eq "^[[:space:]]*compress([[:space:]]|$)" "$LR"'
need "$LR creates the new log with 0640 root adm" 'grep -Eq "^[[:space:]]*create[[:space:]]+0?640[[:space:]]+root[[:space:]]+adm([[:space:]]|$)" "$LR"'
need "$W/access.log is a new empty log" '[ -f $W/access.log ] && [ ! -s $W/access.log ]'
need "$W/access.log is -rw-r----- root adm" '[ "$(stat -c "%a %U %G" $W/access.log)" = "640 root adm" ]'
need "the old lines are in access.log.1.gz (or access.log.1)" '{ zcat $W/access.log.1.gz 2>/dev/null || cat $W/access.log.1 2>/dev/null; } | grep -q .'

task 3 "The webapp messages of priority err and worse in /root/lab-answers/3"
need "/root/lab-answers/3 has the error: cannot connect to database" 'ans 3 | grep -qF "cannot connect to database"'
need "/root/lab-answers/3 has the critical message: worker threads stuck" 'ans 3 | grep -qF "worker threads stuck"'
need "/root/lab-answers/3 has nothing below err (no warning, no notice)" '! ans 3 | grep -qE "cache warmed|disk use at"'
