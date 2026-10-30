LOG=$LAB_STATE/watch.log

task 1 "svcbak: UID 2001, comment Backup account, no login shell"
need "svcbak existed with UID 2001, Backup account and /sbin/nologin" 'grep -Eq "svcbak:x:2001:[0-9]+:Backup account:/home/svcbak:/(usr/)?sbin/nologin" "$LOG"'

task 2 "carol's home moved to /home/carol2 with its files; comment Carol Smith"
need "carol existed with comment Carol Smith and home /home/carol2" 'grep -Eq "carol:x:[0-9]+:[0-9]+:Carol Smith:/home/carol2:" "$LOG"'
need "/home/carol2 held the files from /etc/skel then" 'grep -E "carol:x:[0-9]+:[0-9]+:[^:]*:/home/carol2:" "$LOG" | grep -q "carol2=.*\.bashrc"'

task 3 "carol deleted with her home, svcbak without; leftovers found"
need "carol is gone" '! getent passwd carol'
need "/home/carol2 is gone" '[ ! -e /home/carol2 ]'
need "svcbak is gone" '! getent passwd svcbak'
need "/home/svcbak is still there" '[ -d /home/svcbak ]'
need "/root/lab-answers/3 lists /home/svcbak" 'grep -Eqx "/home/svcbak/?" /root/lab-answers/3'
