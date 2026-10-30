A1=/root/lab-answers/1
held_pid() { systemctl show -p MainPID --value le-lab-held.service; }

task 1 "Large and set-user-ID files listed"
need "the list names the file over 50 MiB under /var/lib" 'grep -q /var/lib/le-report/archive.dat "$A1"'
need "the list names the set-user-ID program under /usr/local" 'grep -q /usr/local/sbin/le-backup-helper "$A1"'
need "the list names the usual set-user-ID programs (such as passwd)" 'grep -q /usr/bin/passwd "$A1" && grep -q /usr/bin/su "$A1"'

task 2 "locate finds ~/findme-*.txt"
need "a file ~/findme-*.txt exists" 'ls /root/findme-*.txt'
need "locate findme- lists it" 'for f in /root/findme-*.txt; do locate findme- | grep -qxF "$f" && exit 0; done; exit 1'

task 3 "Hard link survives, symbolic link dangles"
need "/tmp/t.txt is deleted" '[ ! -e /tmp/t.txt ] && [ ! -L /tmp/t.txt ]'
need "/tmp/h.txt is a regular file containing hi" '[ -f /tmp/h.txt ] && [ ! -L /tmp/h.txt ] && [ "$(cat /tmp/h.txt)" = hi ]'
need "/tmp/h.txt is the last name of its inode" '[ "$(stat -c %h /tmp/h.txt)" = 1 ]'
need "/tmp/s.txt is a symbolic link to t.txt" '[ -L /tmp/s.txt ] && [ "$(basename "$(readlink /tmp/s.txt)")" = t.txt ]'

task 4 "The PID holding /tmp/held.txt open"
need "/root/lab-answers/4 has the PID" '[ -n "$(held_pid)" ] && [ "$(answer 4)" = "$(held_pid)" ]'
