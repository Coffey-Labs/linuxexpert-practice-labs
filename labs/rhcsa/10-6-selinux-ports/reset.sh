for f in /etc/httpd/conf.d/*; do
	[ -e "$f" ] || continue
	grep -qxF "${f##*/}" "$LAB_STATE/conf-d" 2>/dev/null && continue
	grep -qw 8888 "$f" && rm -f "$f"
done
sed -i -E '/^[[:space:]]*Listen[[:space:]]+8888[[:space:]]*$/d' /etc/httpd/conf/httpd.conf 2>/dev/null
if [ -f "$LAB_STATE/index.html" ]; then cp -a "$LAB_STATE/index.html" /var/www/html/index.html
else rm -f /var/www/html/index.html; fi
if [ -n "$(state_get httpd-was-enabled)" ]; then systemctl restart httpd 2>/dev/null
else systemctl disable --now --quiet httpd 2>/dev/null; fi
if [ -f "$LAB_STATE/ssh.tar" ]; then
	rm -f /etc/ssh/sshd_config.d/*
	tar -C /etc -xf "$LAB_STATE/ssh.tar"
	sshd -t && systemctl restart sshd
fi
if command -v semanage >/dev/null; then
	[ -n "$(state_get had-8888)" ] || semanage port -d -t http_port_t -p tcp 8888 2>/dev/null
	[ -n "$(state_get had-2222)" ] || semanage port -d -t ssh_port_t -p tcp 2222 2>/dev/null
fi
if [ -f "$LAB_STATE/firewalld.tar" ]; then
	rm -rf /etc/firewalld
	tar -C /etc -xf "$LAB_STATE/firewalld.tar"
	systemctl is-active --quiet firewalld && firewall-cmd -q --reload
fi
true
