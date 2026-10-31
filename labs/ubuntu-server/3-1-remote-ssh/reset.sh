if [ -f "$LAB_STATE/ssh.tar" ]; then
	rm -f /etc/ssh/sshd_config.d/*
	tar -C /etc -xf "$LAB_STATE/ssh.tar"
fi
for f in /etc/systemd/system/ssh.socket.d/*; do
	[ -e "$f" ] || continue
	grep -qxF "${f##*/}" "$LAB_STATE/socket-d" 2>/dev/null || rm -f "$f"
done
rmdir /etc/systemd/system/ssh.socket.d 2>/dev/null
systemctl daemon-reload
# Restarting the socket restarts sshd with the old settings too. Restarting
# ssh.service as well, or too often, trips its start limit and leaves
# nothing on port 22, so clear the counter and check.
for i in 1 2 3; do
	systemctl reset-failed ssh.service ssh.socket 2>/dev/null
	systemctl restart ssh.socket 2>/dev/null
	sleep 2
	ss -Hltn 'sport = :22' | grep -q . && ! systemctl is-failed --quiet ssh.service && break
done
for x in ann ben; do
	pkill -KILL -u "$x" 2>/dev/null
	userdel -r "$x" 2>/dev/null
done
groupdel remote 2>/dev/null
true
