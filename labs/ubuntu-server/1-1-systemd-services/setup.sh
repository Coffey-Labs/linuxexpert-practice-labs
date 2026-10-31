[ -e /etc/systemd/system/hello.service ] && refuse "/etc/systemd/system/hello.service already exists; move it away and start again"
ss -Hltn 'sport = :8080' | grep -q . && refuse "something already listens on port 8080; stop it and start again"
# Reset removes the packages installed from here on, and only those.
dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }' | sort -u >"$LAB_STATE/pkgs-before"
pkg_installed nginx && state_set had-nginx 1
true
