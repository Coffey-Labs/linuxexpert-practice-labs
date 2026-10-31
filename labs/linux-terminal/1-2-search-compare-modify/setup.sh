grep -qx '#Port 22' /etc/ssh/sshd_config ||
	refuse "/etc/ssh/sshd_config has no line '#Port 22' for task 3; put it back as Ubuntu ships it and start the lab again."
user_add student
H=$(getent passwd student | cut -d: -f6)
state_set home "$H"
rm -f "$H/bash-users.txt" "$H/big-etc.txt" "$H/sshd.copy" "$H/sshd.copy.bak"
cp /etc/ssh/sshd_config "$LAB_STATE/sshd_config"
true
