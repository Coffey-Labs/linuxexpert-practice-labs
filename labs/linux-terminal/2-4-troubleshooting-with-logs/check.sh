START=$(state_get start)
ans() { tr 'A-Z' 'a-z' <"/root/lab-answers/$1" 2>/dev/null; }
NAME=$(head -n1 /root/lab-answers/2 2>/dev/null | tr -d '[:space:]')
invalid_in_authlog() { grep -h sshd /var/log/auth.log /var/log/auth.log.1 2>/dev/null | grep -qF "Invalid user $NAME from 10.99.0.2 "; }
invalid_in_journal() { journalctl -q -u ssh -u ssh.socket --since "$START" --no-pager | grep -qF "Invalid user $NAME from 10.99.0.2 "; }

task 1 "broken.service started, and its failure found: 203/EXEC"
need "/etc/systemd/system/broken.service has ExecStart=/usr/local/bin/missing" 'grep -Eq "^ExecStart=/usr/local/bin/missing[[:space:]]*$" /etc/systemd/system/broken.service'
need "systemd has loaded it (daemon-reload)" '[ "$(systemctl show -p LoadState --value broken.service)" = loaded ] && [ "$(systemctl show -p NeedDaemonReload --value broken.service)" = no ]'
need "it was started and failed: journalctl -u broken shows status=203/EXEC" 'journalctl -q -u broken --since "$START" --no-pager | grep -q "status=203/EXEC"'
need "/root/lab-answers/1 has the exit status, 203/EXEC" 'ans 1 | grep -q "203"'

task 2 "A failed SSH login from the peer as a user that doesn't exist"
need "/root/lab-answers/2 holds a user name" '[ -n "$NAME" ]'
need "$NAME isn't a user on this system" '! getent passwd "$NAME"'
need "/var/log/auth.log has Invalid user $NAME from 10.99.0.2" invalid_in_authlog
need "journalctl -u ssh shows the same line" invalid_in_journal

task 3 "The kernel's err-or-worse messages from the last hour in /root/lab-answers/3"
need "/root/lab-answers/3 has the kernel's medium error on sector 4242" 'ans 3 | grep -qF "medium error on sector 4242"'
need "/root/lab-answers/3 has only the kernel's messages (not the backup error)" '! ans 3 | grep -qF "backup of /srv failed"'
