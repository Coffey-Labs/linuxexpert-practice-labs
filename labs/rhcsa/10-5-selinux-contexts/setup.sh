command -v getenforce >/dev/null && [ "$(getenforce)" = Enforcing ] || refuse "SELinux isn't enforcing; set SELINUX=enforcing in /etc/selinux/config, reboot, and start again"
[ -e /web ] && refuse "/web already exists; remove it and start again"
pkg_installed httpd && state_set httpd-before 1
pkg_installed httpd || pkg_install httpd
pkg_installed policycoreutils-python-utils || pkg_install policycoreutils-python-utils
enabled httpd && state_set httpd-was-enabled 1
ls -A /etc/httpd/conf.d >"$LAB_STATE/conf-d"
mkdir -p /web
echo '<h1>Lab page from /web</h1>' >/web/index.html
chcon -R -t default_t /web
echo '<p>Label test page</p>' >/var/www/html/label.html
restorecon /var/www/html/label.html
rm -f /var/www/html/page.html /tmp/page.html
systemctl enable --now --quiet httpd
