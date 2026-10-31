id bob >/dev/null 2>&1 && refuse "user bob already exists; task 2 creates him. Remove him (userdel -r bob) and start the lab again."
user_add student
H=$(getent passwd student | cut -d: -f6)
state_set home "$H"
rm -f "$H/.ssh/lab_key" "$H/.ssh/lab_key.pub"
state_set start "$(date '+%Y-%m-%d %H:%M:%S')"
wc -c </var/log/auth.log >"$LAB_STATE/auth-size" 2>/dev/null || true
true
