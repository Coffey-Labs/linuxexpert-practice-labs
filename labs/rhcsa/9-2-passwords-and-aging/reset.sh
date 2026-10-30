[ -f "$LAB_STATE/login.defs" ] && cp -a "$LAB_STATE/login.defs" /etc/login.defs
# Test users made since the lab started.
if [ -f "$LAB_STATE/users-before" ]; then
	getent passwd | awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' | while read -r u; do
		grep -qxF "$u" "$LAB_STATE/users-before" || userdel -r "$u" >/dev/null 2>&1
	done
fi
true
