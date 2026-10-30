systemctl start tuned 2>/dev/null
if [ "$(cat "$LAB_STATE/profile_mode" 2>/dev/null)" = auto ]; then
	tuned-adm auto_profile
elif [ -s "$LAB_STATE/active_profile" ]; then
	tuned-adm profile $(cat "$LAB_STATE/active_profile")
fi
[ "$(state_get was-enabled)" = enabled ] || systemctl disable --quiet tuned 2>/dev/null
[ "$(state_get was-active)" = active ] || systemctl stop tuned 2>/dev/null
true
