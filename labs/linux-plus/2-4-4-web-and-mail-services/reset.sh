rm -f /etc/nginx/conf.d/lab.conf /etc/httpd/conf.d/shop.conf
grep -ls 'lab\.test' /etc/nginx/conf.d/*.conf 2>/dev/null | xargs -r rm -f
grep -ls 'shop\.test' /etc/httpd/conf.d/*.conf 2>/dev/null | xargs -r rm -f
command -v semanage >/dev/null && semanage fcontext -d '/srv/www(/.*)?' 2>/dev/null
rm -rf /srv/www
for p in nginx httpd postfix s-nail mailutils policycoreutils-python-utils; do
	[ -n "$(state_get had-$p)" ] && continue
	pkg_installed $p || continue
	systemctl disable --now --quiet $p 2>/dev/null
	if is_rhel; then
		dnf -y -q remove $p >/dev/null
	else
		pkgs=$p
		[ $p = nginx ] && pkgs="nginx nginx-common"
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge $pkgs >/dev/null 2>&1
	fi
done
for p in nginx httpd; do [ -n "$(state_get had-$p)" ] && systemctl try-restart $p 2>/dev/null; done
true
