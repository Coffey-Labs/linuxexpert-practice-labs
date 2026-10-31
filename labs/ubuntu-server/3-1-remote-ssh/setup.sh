u=${SUDO_USER:-}
[ -n "$u" ] && [ "$u" != root ] || refuse "start this lab with sudo from your own account (task 1 lets only group remote log in, and your account must be in it)"
for x in ann ben; do id "$x" >/dev/null 2>&1 && refuse "a user $x already exists; remove it and start again"; done
getent group remote >/dev/null && refuse "a group remote already exists; remove it and start again"
state_set student "$u"
tar -C /etc -cf "$LAB_STATE/ssh.tar" ssh
ls /etc/systemd/system/ssh.socket.d >"$LAB_STATE/socket-d" 2>/dev/null || true
