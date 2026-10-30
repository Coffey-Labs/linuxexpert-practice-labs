uid_min=$(awk '$1 == "UID_MIN" {print $2}' /etc/login.defs)
admin=$(pick wheel sudo)
field() { getent passwd "$1" | cut -d: -f"$2"; }

task 1 "UID_MIN found"
need "/root/lab-answers/1 has UID_MIN from /etc/login.defs" '[ -n "$uid_min" ] && [ "$(answer 1)" = "$uid_min" ]'

task 2 "skel bin, labuser, labgroup and service account labsvc"
need "/etc/skel/bin is a directory" '[ -d /etc/skel/bin ]'
need "user labuser exists" id labuser
need "labuser's comment is Lab User" '[ "$(field labuser 5)" = "Lab User" ]'
need "labuser's shell is /bin/bash" '[ "$(field labuser 7)" = /bin/bash ]'
need "labuser's home directory has bin from /etc/skel" '[ -d "$(field labuser 6)/bin" ]'
need "labuser is in group labgroup" 'id -nG labuser | grep -qw labgroup'
need "user labsvc exists" id labsvc
need "labsvc is a system account (UID below UID_MIN)" '[ "$(id -u labsvc)" -lt "$uid_min" ]'
need "labsvc has no home directory" '[ ! -d "$(field labsvc 6)" ]'
need "labsvc can't log in (nologin shell)" '[[ "$(field labsvc 7)" == */nologin ]]'

task 3 "labuser in labgroup and the administrators' group"
need "labuser is in $admin" 'id -nG labuser | grep -qw "$admin"'
need "labuser is still in labgroup" 'id -nG labuser | grep -qw labgroup'
