for p in 80 8080 8081; do listening $p tcp && refuse "something already listens on port $p; stop it and start again"; done
[ -e /root/scans ] && refuse "/root/scans already exists; move it away and start again"
command -v nft >/dev/null && nft list table inet scanlab >/dev/null 2>&1 && refuse "an nftables table inet scanlab already exists; delete it and start again"
# Reset removes every package installed from here on, by setup or by the
# tasks, and only those.
pkgs_now() { if is_rhel; then rpm -qa --qf '%{NAME}\n'; else dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }'; fi | sort -u; }
pkgs_now >"$LAB_STATE/pkgs-before"
if systemctl is-active --quiet firewalld; then
	tar -C /etc -cf "$LAB_STATE/firewalld.tar" firewalld
elif command -v ufw >/dev/null && ufw status | grep -q 'Status: active'; then
	tar -C /etc -cf "$LAB_STATE/ufw.tar" ufw
fi
enabled nginx && state_set nginx-enabled 1
peer_up

# nginx on 80, 8080 and 8081.
pkg_install nginx
if is_rhel && selinuxenabled 2>/dev/null; then
	# SELinux lets the web server use 8080, but 8081 has another label.
	pkg_install policycoreutils-python-utils
	semanage port -m -t http_port_t -p tcp 8081
	state_set semanage-8081 1
fi
cat >/etc/nginx/conf.d/lab.conf <<'X'
server {
    listen 8080;
    listen 8081;
    return 200 "lab app\n";
}
X
systemctl restart nginx
