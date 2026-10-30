command -v getenforce >/dev/null && [ "$(getenforce)" = Enforcing ] || refuse "SELinux isn't enforcing; set SELINUX=enforcing in /etc/selinux/config, reboot, and start again"
pkg_installed httpd || pkg_install httpd
pkg_installed policycoreutils-python-utils || pkg_install policycoreutils-python-utils
enabled httpd && state_set httpd-was-enabled 1
semanage port -l -C | grep -Eq '^http_port_t[[:space:]]+tcp[[:space:]].*\b8888\b' && state_set had-8888 1
semanage port -l -C | grep -Eq '^ssh_port_t[[:space:]]+tcp[[:space:]].*\b2222\b' && state_set had-2222 1
ls -A /etc/httpd/conf.d >"$LAB_STATE/conf-d"
tar -C /etc -cf "$LAB_STATE/ssh.tar" ssh
if systemctl is-active --quiet firewalld; then
	state_set firewalld 1
	tar -C /etc -cf "$LAB_STATE/firewalld.tar" firewalld
fi
[ -f /var/www/html/index.html ] && cp -a /var/www/html/index.html "$LAB_STATE/index.html"
echo 'Lab httpd' >/var/www/html/index.html
restorecon /var/www/html/index.html
systemctl enable --now --quiet httpd
peer_up
