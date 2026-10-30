if pkg_installed httpd; then
	systemctl disable --now --quiet httpd 2>/dev/null
	dnf -y -q remove httpd >/dev/null
fi
[ -n "$(state_get had-etc-httpd)" ] || rm -rf /etc/httpd
true
