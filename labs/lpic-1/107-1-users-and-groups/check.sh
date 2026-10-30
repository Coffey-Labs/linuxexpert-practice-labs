sh_field() { getent shadow "$1" | cut -d: -f"$2"; }
SYS_MAX=$(awk '$1 == "SYS_UID_MAX" {print $2}' /etc/login.defs)
SYS_MAX=${SYS_MAX:-999}

task 1 "Group developers; dana with home, comment, /bin/sh and that group"
need "group developers exists" 'getent group developers'
need "user dana exists" 'id dana'
need "dana has a home directory" '[ -d "$(getent passwd dana | cut -d: -f6)" ]'
need "dana's comment is Dana Lee" '[ "$(getent passwd dana | cut -d: -f5 | cut -d, -f1)" = "Dana Lee" ]'
need "dana's shell is /bin/sh" '[ "$(getent passwd dana | cut -d: -f7)" = /bin/sh ]'
need "dana is in developers" 'id -nG dana | grep -qw developers'

task 2 "usermod -G without -a, and the lost group in /root/lab-answers/2"
need "dana is in developers" 'id -nG dana | grep -qw developers'
need "dana isn't in testers any more" '! id -nG dana | grep -qw testers'
need "the answer is testers" '[ "$(answer 2)" = testers ]'

task 3 "dana's password expires every 30 days, warning 7 days before"
need "maximum password age is 30" '[ "$(sh_field dana 5)" = 30 ]'
need "warning period is 7 days" '[ "$(sh_field dana 6)" = 7 ]'

task 4 "pat must change her password (or already has)"
need "user pat exists" 'id pat'
need "pat's password must be changed at next login, or has been changed" '[ "$(sh_field pat 3)" = 0 ] || [ "$(sh_field pat 2)" != "$(state_get pat-hash)" ]'

task 5 "System account appsvc with a nologin shell"
need "user appsvc exists" 'id appsvc'
need "appsvc is a system account (UID $SYS_MAX or below)" '[ "$(id -u appsvc)" -le "$SYS_MAX" ]'
need "appsvc's shell is nologin" 'getent passwd appsvc | cut -d: -f7 | grep -Eq "/nologin$"'

task 6 "ken and lou deleted, their leftovers in /root/lab-answers/6"
need "user ken is gone" '! getent passwd ken'
need "user lou is gone" '! getent passwd lou'
need "ken's home directory is gone" '[ ! -e /home/ken ]'
need "lou's home directory is still there" '[ -d /home/lou ]'
need "the answer lists /var/tmp/ken-report.txt" 'grep -qx "/var/tmp/ken-report.txt" /root/lab-answers/6'
need "the answer lists /home/lou" 'grep -qx "/home/lou/\?" /root/lab-answers/6'
