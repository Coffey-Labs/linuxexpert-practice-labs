F=/usr/share/zoneinfo/Pacific/Pitcairn
[ -f "$LAB_STATE/tzfile" ] && cp -a "$LAB_STATE/tzfile" $F
rm -f /etc/ssh/lab-new-file /root/lab-aide.conf /root/lab-aide.db /root/lab-aide.db.new
if [ -f "$LAB_STATE/ssh.tar" ]; then
	rm -f /etc/ssh/sshd_config.d/*
	tar -C /etc -xf "$LAB_STATE/ssh.tar"
	command -v restorecon >/dev/null && restorecon -R /etc/ssh
fi
if [ -f "$LAB_STATE/issue.net" ]; then
	cp -a "$LAB_STATE/issue.net" /etc/issue.net
fi
rm -f /etc/issue.net.orig
if is_rhel; then systemctl reload sshd; else mkdir -p /run/sshd; systemctl reload ssh 2>/dev/null || systemctl restart ssh; fi
true
