rm -f /var/www/html/moved.html
setsebool -P httpd_enable_homedirs off 2>/dev/null
if [ -z "$(state_get httpd-was-active)" ]; then
	systemctl stop --quiet httpd 2>/dev/null
fi
[ -n "$(state_get httpd-was-enabled)" ] || systemctl disable --quiet httpd 2>/dev/null
true
