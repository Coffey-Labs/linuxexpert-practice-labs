if id bob >/dev/null 2>&1; then
	pkill -KILL -u bob 2>/dev/null
	userdel -r bob 2>/dev/null
fi
H=$(state_get home)
[ -n "$H" ] && rm -f "$H/.ssh/lab_key" "$H/.ssh/lab_key.pub"
true
