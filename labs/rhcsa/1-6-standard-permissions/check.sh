task 1 "/srv/reports/q3.txt: alice and wheel, -rw-r-----"
need "/srv/reports/q3.txt exists" '[ -f /srv/reports/q3.txt ]'
need "it's owned by alice and the group wheel" '[ "$(stat -c "%U %G" /srv/reports/q3.txt)" = "alice wheel" ]'
need "its mode is 640 (-rw-r-----)" '[ "$(stat -c %a /srv/reports/q3.txt)" = 640 ]'

task 2 "/srv/reports usable by its group, closed to others"
need "/srv/reports has mode 770" '[ "$(stat -c %a /srv/reports)" = 770 ]'
need "bob, not in the directory's group, can't list it" '! id -nG bob | grep -qw "$(stat -c %G /srv/reports)" && ! runuser -u bob -- ls /srv/reports'

task 3 "/srv/project: directories 755, files 644"
need "every directory under /srv/project is 755" '[ -z "$(find /srv/project -type d ! -perm 755)" ]'
need "every file under /srv/project is 644" '[ -z "$(find /srv/project -type f ! -perm 644)" ]'
need "the files are all still there" '[ "$(find /srv/project -type f | wc -l)" = 6 ]'

task 4 "The blocking directory found; alice can read app.conf"
need "/root/lab-answers/4 names /opt/app/conf" '[ "$(answer 4 | sed "s|/*$||")" = /opt/app/conf ]'
need "alice can read /opt/app/conf/app.conf" 'runuser -u alice -- cat /opt/app/conf/app.conf'
need "app.conf is still mode 644" '[ "$(stat -c %a /opt/app/conf/app.conf)" = 644 ]'
