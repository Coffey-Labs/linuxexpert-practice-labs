[ "$(getenforce 2>/dev/null)" = Enforcing ] || refuse "SELinux isn't enforcing; set SELINUX=enforcing in /etc/selinux/config, reboot, and start again"
[ -e /var/www/html/moved.html ] && refuse "/var/www/html/moved.html already exists; remove it and start again"
systemctl is-active --quiet httpd && state_set httpd-was-active 1
systemctl is-enabled --quiet httpd 2>/dev/null && state_set httpd-was-enabled 1
if [ -z "$(state_get httpd-was-active)" ]; then
	systemctl disable --now --quiet httpd 2>/dev/null || true
fi
setsebool -P httpd_enable_homedirs off
true
