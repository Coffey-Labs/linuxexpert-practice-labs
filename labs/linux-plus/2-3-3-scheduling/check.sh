# Every user crontab on the system, RHEL or Debian layout.
crontabs() { cat /var/spool/cron/[!c]* /var/spool/cron/crontabs/* 2>/dev/null | grep -v '^[[:space:]]*#'; }

task 1 "Cron appended the date every minute, then the job was removed"
need "/tmp/cron-test.txt has at least two lines" '[ "$(wc -l </tmp/cron-test.txt)" -ge 2 ]'
need "no crontab still writes to cron-test.txt" '! crontabs | grep -q cron-test'

task 2 "Cron's environment saved, then the job was removed"
need "/tmp/cron-env.txt holds a cron job's environment" 'grep -qx "SHELL=/bin/sh" /tmp/cron-env.txt && grep -q "^PATH=" /tmp/cron-env.txt'
need "no crontab still writes to cron-env.txt" '! crontabs | grep -q cron-env'

task 3 "atd running and enabled, the at job ran"
need "at is installed" 'command -v at'
need "atd is running" active atd
need "atd starts at boot" enabled atd
need "/tmp/at-ran exists" '[ -e /tmp/at-ran ]'
