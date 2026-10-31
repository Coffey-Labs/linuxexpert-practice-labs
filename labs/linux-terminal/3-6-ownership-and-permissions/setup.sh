[ -e /srv/finance ] && refuse "/srv/finance already exists; task 1 creates it. Remove it and start the lab again."
getent group finance >/dev/null && refuse "group finance already exists; task 1 creates it. Remove it and start the lab again."
user_add ana
user_add ben
user_add student
H=$(getent passwd student | cut -d: -f6)
state_set home "$H"
rm -rf "$H/private"
true
