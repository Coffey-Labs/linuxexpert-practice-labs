# The nodes go with nodes_down and greg (with his project) with
# users_remove; here, what the tasks and then setup installed on this VM.
if [ -f "$LAB_STATE/rpms" ]; then
	new=$(comm -13 "$LAB_STATE/rpms" <(rpm -qa --qf '%{NAME}\n' | sort -u))
	[ -z "$new" ] || dnf -y -q remove $new >/dev/null 2>&1
fi
while read -r p; do dnf -y -q remove "$p" >/dev/null 2>&1; done <"$LAB_STATE/missing" 2>/dev/null
true
