task 1 "The section of /etc/crontab's format in /root/lab-answers/1"
need "/root/lab-answers/1 holds the right section" '[ "$(answer 1)" = 5 ]'

task 2 "The sshd_config keyword and value in /root/lab-answers/2"
need "/root/lab-answers/2 holds the keyword and its current value" '[ "$(answer 2 | tr -s " \t" "  ")" = "$(sshd -T 2>/dev/null | grep -i "^maxauthtries ")" ]'

task 3 "The man page index rebuilt"
need "/var/cache/man/index.db exists again" '[ -f /var/cache/man/index.db ]'
need "man -k timer lists systemd.timer (5)" 'man -k timer | grep -q "^systemd\.timer (5)"'

task 4 "sudo's example sudoers file in /root/lab-answers/4"
need "/root/lab-answers/4 holds its full path" '[ "$(head -n1 /root/lab-answers/4 2>/dev/null | tr -d " \t")" = "$(rpm -qd sudo | grep "examples/sudoers$")" ]'
