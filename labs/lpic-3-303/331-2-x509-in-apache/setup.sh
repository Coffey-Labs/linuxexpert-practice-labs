listening 443 tcp && refuse "something already listens on port 443; stop it and start again"
pgrep -f '^openssl ocsp' >/dev/null && refuse "an openssl ocsp responder is already running; stop it and start again"
[ -e /root/tls ] && refuse "/root/tls already exists; move it away and start again"
# Reset removes every package installed from here on, by setup or by the
# tasks, and only those.
pkgs_now() { if is_rhel; then rpm -qa --qf '%{NAME}\n'; else dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }'; fi | sort -u; }
pkgs_now >"$LAB_STATE/pkgs-before"
command -v openssl >/dev/null || pkg_install openssl
hosts_add "127.0.0.1 alpha.test beta.test"
# Apache's configuration, if it's there, for reset to put back.
D=$(pick /etc/httpd /etc/apache2)
[ -d "$D" ] && tar -C / -cf "$LAB_STATE/apache.tar" "${D#/}"
if is_rhel; then
	getsebool httpd_can_network_connect 2>/dev/null | grep -q 'on$' && state_set had-nc 1
	semanage port -l 2>/dev/null | grep -w 8888 >"$LAB_STATE/port-8888" || true
fi
pkg_installed "$(pick httpd apache2)" && enabled "$(pick httpd apache2)" && state_set was-enabled 1
true
