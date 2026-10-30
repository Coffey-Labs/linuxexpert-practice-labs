id dave >/dev/null 2>&1 && refuse "user dave already exists; remove it and start again"
cp -a /etc/login.defs "$LAB_STATE/login.defs"
# A fresh start for task 2.
if grep -Eq '^[[:space:]]*PASS_MAX_DAYS[[:space:]]+90[[:space:]]*$' /etc/login.defs; then
	sed -i -E 's/^[[:space:]]*PASS_MAX_DAYS[[:space:]].*/PASS_MAX_DAYS\t99999/' /etc/login.defs
fi
user_add dave
state_set dave-max "$(getent shadow dave | cut -d: -f5)"
getent passwd | awk -F: '{print $1}' >"$LAB_STATE/users-before"
