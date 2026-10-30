task 1 "Output in /tmp/ok.txt, the error in /tmp/errors.txt"
need "/tmp/ok.txt holds only /etc/hostname" '[ "$(cat /tmp/ok.txt)" = /etc/hostname ]'
need "/tmp/errors.txt holds one line" '[ "$(wc -l </tmp/errors.txt)" = 1 ]'
need "/tmp/errors.txt holds the error about /nonexistent" 'grep -q "/nonexistent.*No such file" /tmp/errors.txt'

task 2 "The date appended to /tmp/log.txt three times"
need "/tmp/log.txt has 3 lines" '[ "$(wc -l </tmp/log.txt)" = 3 ]'
need "every line holds a date with a time" '[ "$(grep -Ec "[0-9]{1,2}:[0-9]{2}:[0-9]{2}" /tmp/log.txt)" = 3 ]'

task 3 "Every .conf file under /etc listed in /tmp/confs.txt, no errors"
need "/tmp/confs.txt isn't empty" '[ -s /tmp/confs.txt ]'
need "it holds no error messages" '! grep -Eiq "denied|no such file|^find:" /tmp/confs.txt'
need "every line is a path under /etc ending in .conf" '! grep -Ev "^/etc/.*\.conf$" /tmp/confs.txt | grep -q .'
need "it lists the .conf files a normal user can find, such as /etc/dnf/dnf.conf" '
	grep -qx /etc/dnf/dnf.conf /tmp/confs.txt &&
	n=$(runuser -u nobody -- find /etc -name "*.conf" 2>/dev/null | wc -l) &&
	[ "$(wc -l </tmp/confs.txt)" -ge $((n * 9 / 10)) ]'

task 4 "192.0.2.50 test.example.com in /etc/hosts"
need "/etc/hosts has the line" 'grep -Eq "^192\.0\.2\.50[[:space:]]+test\.example\.com([[:space:]]|$)" /etc/hosts'
need "getent hosts test.example.com prints 192.0.2.50" 'getent hosts test.example.com | grep -q "^192\.0\.2\.50 "'
