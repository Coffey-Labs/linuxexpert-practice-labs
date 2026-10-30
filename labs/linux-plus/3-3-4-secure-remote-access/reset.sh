pkill -f '19090:localhost:9090' 2>/dev/null
systemctl disable --now --quiet le-lab-console.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-console.service
rm -rf /srv/le-console /usr/local/lib/le-lab/httpd.py
rmdir /usr/local/lib/le-lab 2>/dev/null
if [ -f "$LAB_STATE/ssh.tar" ]; then
	rm -f /etc/ssh/sshd_config.d/*
	tar -C /etc -xf "$LAB_STATE/ssh.tar"
	command -v restorecon >/dev/null && restorecon -R /etc/ssh
fi
systemctl daemon-reload
if is_rhel; then systemctl restart sshd; else systemctl restart ssh; fi
true
