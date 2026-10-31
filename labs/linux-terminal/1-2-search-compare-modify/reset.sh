H=$(state_get home)
[ -n "$H" ] && rm -f "$H/bash-users.txt" "$H/big-etc.txt" "$H/sshd.copy" "$H/sshd.copy.bak"
true
