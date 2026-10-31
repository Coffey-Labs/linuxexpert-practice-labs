q() { mysql -N -B -e "$1" 2>/dev/null; }
grants() { q "SHOW GRANTS FOR 'shopapp'@'localhost'"; }
# The shop site's configuration file, from apache2ctl -S.
site_conf() { apache2ctl -S 2>/dev/null | awk '/namevhost shop\.example\.test / { sub(/.*\(/, ""); sub(/:[0-9]+\)$/, ""); print; exit }'; }
# Its ErrorLog, as a path.
site_log() {
	local f l
	f=$(site_conf); [ -f "$f" ] || return 1
	l=$(awk 'tolower($1) == "errorlog" { print $2; exit }' "$f" | tr -d '"')
	[ -n "$l" ] || return 1
	l=${l//'${APACHE_LOG_DIR}'/\/var\/log\/apache2}
	case $l in /*) ;; *) l=/etc/apache2/$l ;; esac
	echo "$l"
}
page() { curl -s --max-time 10 -H 'Host: shop.example.test' http://localhost/; }
code() { curl -s -o /dev/null --max-time 10 -w '%{http_code}' -H 'Host: shop.example.test' http://localhost/; }
# Every row of shop.item shows up in the page by at least one text value.
items_shown() {
	local p row v found
	p=$(page)
	[ "$(q 'SELECT COUNT(*) FROM shop.item')" -ge 2 ] || return 1
	while IFS= read -r row; do
		found=
		while IFS= read -r v; do
			[ "${#v}" -ge 2 ] && ! [[ $v =~ ^[0-9.]+$ ]] && grep -qF -- "$v" <<<"$p" && found=1
		done < <(tr '\t' '\n' <<<"$row")
		[ -n "$found" ] || return 1
	done < <(q 'SELECT * FROM shop.item')
}

task 1 "Database shop, table item with two rows, read-only user shopapp"
need "Apache, PHP and MySQL are installed" 'pkg_installed apache2 && pkg_installed mysql-server && ls /etc/apache2/mods-enabled/php*.load'
need "MySQL is running" 'active mysql'
need "shop.item holds two rows" '[ "$(q "SELECT COUNT(*) FROM shop.item")" = 2 ]'
need "user shopapp@localhost exists" '[ "$(q "SELECT COUNT(*) FROM mysql.user WHERE user = '"'"'shopapp'"'"' AND host = '"'"'localhost'"'"'")" = 1 ]'
need "shopapp may SELECT from shop" 'grants | grep -Eq "GRANT SELECT ON .shop.\.(\*|.item.) TO"'
need "shopapp may do nothing else" '! grants | grep -Eiq "ALL PRIVILEGES|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER"'

task 2 "A PHP page lists the items at virtual host shop.example.test"
need "Apache is running" 'active apache2'
need "apache2ctl -S lists shop.example.test" 'apache2ctl -S 2>/dev/null | grep -q "namevhost shop\.example\.test "'
need "the site has its own error log" 'l=$(site_log) && [ "$l" != /var/log/apache2/error.log ]'
need "curl -H Host: shop.example.test http://localhost/ shows both items" items_shown
need "curl http://localhost/ still shows Ubuntu's default page" 'curl -s --max-time 10 http://localhost/ | grep -q "Apache2 Ubuntu Default Page"'

task 3 "The broken password found in the site's log, and put back"
need "the site's error log shows Access denied for user 'shopapp'@'localhost'" 'grep -q "Access denied for user '"'"'shopapp'"'"'@'"'"'localhost'"'"'" "$(site_log)"'
need "the page works again (HTTP 200)" '[ "$(code)" = 200 ]'
need "it shows both items" items_shown
