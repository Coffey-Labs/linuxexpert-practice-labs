pw() { getent passwd hana | cut -d: -f"$1"; }
today=$(( $(date -u +%s) / 86400 ))
ans4() { cat /root/lab-answers/4 2>/dev/null; }

task 1 "hana: UID 1500, Hana Ito, /home/hana, bash, in qa, with a password"
need "user hana exists" 'id hana'
need "getent passwd hana shows UID 1500" '[ "$(pw 3)" = 1500 ]'
need "her comment is Hana Ito" '[ "$(pw 5 | cut -d, -f1)" = "Hana Ito" ]'
need "her home is /home/hana, and it exists" '[ "$(pw 6)" = /home/hana ] && [ -d /home/hana ] && [ "$(stat -c %U /home/hana)" = hana ]'
need "her shell is /bin/bash" '[ "$(pw 7)" = /bin/bash ]'
need "she has a group of her own" 'getent group hana | grep -q . && [ "$(id -gn hana)" = hana ]'
need "id hana lists qa" 'id -nG hana | grep -qw qa'
need "she has a password set" 'getent shadow hana | cut -d: -f2 | grep -Eq "^!?\\$"'

task 2 "hana in adm as well as qa"
need "id hana lists adm" 'id -nG hana | grep -qw adm'
need "id hana still lists qa" 'id -nG hana | grep -qw qa'

task 3 "hana can't log in by any means; nothing deleted"
need "user hana and /home/hana still exist" 'id hana && [ -d /home/hana ]'
need "passwd -S hana shows L" '[ "$(passwd -S hana | cut -d" " -f2)" = L ]'
need "chage -l hana shows an account expiry date in the past" 'e=$(getent shadow hana | cut -d: -f8); [ -n "$e" ] && [ "$e" -le "$today" ]'
need "su - hana fails" '! su - hana -c true </dev/null'

task 4 "lou removed with his home; what he left in /root/lab-answers/4"
need "lou's account is gone" '! getent passwd lou'
need "/home/lou is gone" '[ ! -e /home/lou ]'
need "/root/lab-answers/4 lists /var/tmp/lou-build.log" 'ans4 | grep -qF /var/tmp/lou-build.log'
need "/root/lab-answers/4 lists /srv/lou-reports" 'ans4 | grep -qF /srv/lou-reports'
