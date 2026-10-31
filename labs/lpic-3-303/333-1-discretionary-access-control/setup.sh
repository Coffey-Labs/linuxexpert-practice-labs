[ -e /srv/dac ] && refuse "/srv/dac already exists; move it away and start again"
# Reset removes every package installed from here on, by setup or by the
# tasks, and only those.
pkgs_now() { if is_rhel; then rpm -qa --qf '%{NAME}\n'; else dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }'; fi | sort -u; }
pkgs_now >"$LAB_STATE/pkgs-before"
getent group projects >/dev/null || { groupadd projects; state_set added-group 1; }
user_add alice -G projects
user_add bob
true
