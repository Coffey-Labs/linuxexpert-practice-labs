task 1 "The shared file sshd's PAM auth lines use"
need "/root/lab-answers/1 names it" '[ "$(answer 1 | sed "s|.*/||")" = "$(pick password-auth common-auth)" ]'

task 2 "pam_nologin tried with the maintenance message, then removed"
need "/root/lab-answers/2 has the message ssh showed" 'grep -q "Maintenance until 11:00" /root/lab-answers/2'
need "/etc/nologin is gone, so users can log in again" '[ ! -e /etc/nologin ] && [ ! -e /run/nologin ]'

task 3 "The authorization manage-units needs in an active session"
need "/root/lab-answers/3 has it" '[ -n "$(answer 3)" ] && [ "$(answer 3)" = "$(pkaction --verbose --action-id org.freedesktop.systemd1.manage-units | awk "/implicit active:/ {print \$3}")" ]'

task 4 "Join a directory domain, or read about it" self
