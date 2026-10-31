# Reset removes the packages installed from here on, and only those.
dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }' | sort -u >"$LAB_STATE/pkgs-before"
pkg_installed nginx && state_set had-nginx 1
active nginx && state_set nginx-was-active 1
true
