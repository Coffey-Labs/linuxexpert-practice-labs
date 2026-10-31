ss -Hltn 'sport = :80' | grep -q . && refuse "something already listens on port 80; stop it and start again"
# Reset removes the packages installed from here on, and only those.
dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }' | sort -u >"$LAB_STATE/pkgs-before"
pkg_installed mysql-server && state_set had-mysql 1
pkg_installed apache2 && state_set had-apache 1
ls /var/www >"$LAB_STATE/www-before" 2>/dev/null || true
ls /etc/apache2/sites-available >"$LAB_STATE/sites-before" 2>/dev/null || true
true
