task 1 "carol: UID 2001, /bin/sh, home, group developers, change at first login"
need "user carol exists" id carol
need "carol has UID 2001" '[ "$(id -u carol)" = 2001 ]'
need "carol's shell is /bin/sh" '[ "$(getent passwd carol | cut -d: -f7)" = /bin/sh ]'
need "carol has a home directory" '[ -d "$(getent passwd carol | cut -d: -f6)" ]'
need "group developers has GID 3000" '[ "$(getent group developers | cut -d: -f3)" = 3000 ]'
need "carol is in group developers" 'id -nG carol | grep -qw developers'
need "carol has a password set" '[ -n "$(getent shadow carol | cut -d: -f2 | tr -d "!*")" ]'
need "carol must change the password at first login" '[ "$(getent shadow carol | cut -d: -f3)" = 0 ]'

task 2 "carol's passwords expire after 60 days, warning 10 days before"
need "maximum password age is 60" '[ "$(getent shadow carol | cut -d: -f5)" = 60 ]'
need "warning period is 10 days" '[ "$(getent shadow carol | cut -d: -f6)" = 10 ]'

task 3 "carol's password locked, account expires 2026-12-31"
need "carol's password is locked" 'passwd -S carol | awk "\$2 ~ /^L/ {ok=1} END {exit !ok}"'
need "the account expires on 2026-12-31" '[ "$(getent shadow carol | cut -d: -f8)" = "$(( $(date -ud 2026-12-31 +%s) / 86400 ))" ]'

task 4 "webadmins may only restart and reload nginx with sudo"
need "sudo rules are valid" visudo -c
need "wendy may run systemctl restart nginx" sudo -n -l -U wendy /usr/bin/systemctl restart nginx
need "wendy may run systemctl reload nginx" sudo -n -l -U wendy /usr/bin/systemctl reload nginx
need "wendy may not run systemctl stop nginx" '! sudo -n -l -U wendy /usr/bin/systemctl stop nginx'
need "wendy may not run a shell" '! sudo -n -l -U wendy /bin/bash'
need "the rule is for group webadmins, not just wendy" 'grep -rqs "^[[:space:]]*%webadmins" /etc/sudoers /etc/sudoers.d'

task 5 "dave removed, his leftover files listed in /root/lab-answers/5"
need "user dave is gone" '! getent passwd dave'
need "dave's home directory is gone" '[ ! -e /home/dave ]'
need "the answer lists /srv/projects/dave-notes.txt" grep -qxF /srv/projects/dave-notes.txt /root/lab-answers/5
need "the answer lists /var/tmp/dave-scratch.tmp" grep -qxF /var/tmp/dave-scratch.tmp /root/lab-answers/5
