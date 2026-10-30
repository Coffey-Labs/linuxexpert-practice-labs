task 1 "Lines of /etc/services with ich in /root/ich.txt"
need "/root/ich.txt exists" '[ -s /root/ich.txt ]'
need "it matches grep ich /etc/services, in order" 'diff -q <(grep ich /etc/services) /root/ich.txt'

task 2 "Active settings of sshd_config in /root/lab-answers/2"
need "/root/lab-answers/2 isn't empty" '[ -s /root/lab-answers/2 ]'
need "it has no comment lines" '! grep -Eq "^[[:space:]]*#" /root/lab-answers/2'
need "it has no blank lines" '! grep -Eq "^[[:space:]]*$" /root/lab-answers/2'
need "it has every active setting of /etc/ssh/sshd_config" 'grep -Ev "^[[:space:]]*(#|$)" /etc/ssh/sshd_config | grep -vxFf /root/lab-answers/2 | { ! grep -q .; }'

task 3 "Users whose shell is /bin/bash in /root/lab-answers/3"
need "/root/lab-answers/3 lists grace and henry" 'grep -qx grace /root/lab-answers/3 && grep -qx henry /root/lab-answers/3'
need "it doesn't list ivan, whose shell is /sbin/nologin" '! grep -qx ivan /root/lab-answers/3'
need "it matches getent passwd exactly" 'diff -q <(getent passwd | awk -F: "\$7 == \"/bin/bash\" {print \$1}" | sort -u) <(tr -s " \t" "\n\n" </root/lab-answers/3 | grep . | sort -u)'

task 4 "Number of nologin lines in /tmp/nologin-count.txt"
need "/tmp/nologin-count.txt holds the number of lines with nologin" '[ "$(tr -dc 0-9 </tmp/nologin-count.txt)" = "$(grep -c nologin /etc/passwd)" ]'
