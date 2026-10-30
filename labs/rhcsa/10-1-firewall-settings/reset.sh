if [ -f "$LAB_STATE/firewalld.tar" ]; then
	rm -rf /etc/firewalld
	tar -C /etc -xf "$LAB_STATE/firewalld.tar"
fi
if [ -n "$(state_get firewalld-was-active)" ]; then
	firewall-cmd -q --reload
else
	systemctl stop firewalld
fi
[ -n "$(state_get firewalld-was-enabled)" ] || systemctl disable --quiet firewalld 2>/dev/null
if [ -f "$LAB_STATE/index.html" ]; then
	cp -a "$LAB_STATE/index.html" /var/www/html/index.html
else
	rm -f /var/www/html/index.html
fi
[ -n "$(state_get httpd-was-enabled)" ] || systemctl disable --now --quiet httpd 2>/dev/null
true
