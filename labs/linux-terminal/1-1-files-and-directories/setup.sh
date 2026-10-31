user_add student
H=$(getent passwd student | cut -d: -f6)
[ -e "$H/lab" ] && refuse "$H/lab already exists; the tasks create it. Remove it and start the lab again."
state_set home "$H"
true
