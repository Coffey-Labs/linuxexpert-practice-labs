if command -v mysql >/dev/null && active mysql; then
	mysql -e "DROP DATABASE IF EXISTS shop; DROP USER IF EXISTS 'shopapp'@'localhost';" 2>/dev/null
fi
# Sites and web directories made since the lab started.
for f in /etc/apache2/sites-available/*; do
	[ -e "$f" ] || continue
	n=${f##*/}
	grep -qxF "$n" "$LAB_STATE/sites-before" 2>/dev/null && continue
	a2dissite -q "${n%.conf}" >/dev/null 2>&1
	rm -f "$f"
done
for d in /var/www/*; do
	[ -e "$d" ] || continue
	grep -qxF "${d##*/}" "$LAB_STATE/www-before" 2>/dev/null && continue
	rm -rf "$d"
done
[ -n "$(state_get had-apache)" ] && systemctl reload apache2 2>/dev/null
# The packages installed since the lab started, and only those.
if [ -s "$LAB_STATE/pkgs-before" ]; then
	new=$(dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }' | sort -u |
		comm -13 "$LAB_STATE/pkgs-before" - | grep -Ev '^linux-')
	if [ -n "$new" ]; then
		say "Removing the packages installed since the lab started..."
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge $new >/dev/null 2>&1
	fi
fi
if [ -z "$(state_get had-mysql)" ]; then
	rm -rf /var/lib/mysql /var/lib/mysql-files /var/lib/mysql-keyring /var/log/mysql /etc/mysql
fi
if [ -z "$(state_get had-apache)" ]; then
	rm -rf /etc/apache2 /var/log/apache2 /var/www/html/index.html
	rmdir /var/www/html 2>/dev/null
fi
true
