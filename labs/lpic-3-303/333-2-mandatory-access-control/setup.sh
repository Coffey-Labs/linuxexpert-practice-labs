[ "$(getenforce 2>/dev/null)" = Enforcing ] || refuse "SELinux isn't enforcing here; run setenforce 1 (and set SELINUX=enforcing) first"
listening 8089 tcp && refuse "something already listens on port 8089; stop it and start again"
for p in /srv/web /root/selinux /var/www/cgi-bin/lab.sh; do
	[ -e $p ] && refuse "$p already exists; move it away and start again"
done
# Reset removes every package installed from here on, by setup or by the
# tasks, and only those.
pkgs_now() { if is_rhel; then rpm -qa --qf '%{NAME}\n'; else dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }'; fi | sort -u; }
pkgs_now >"$LAB_STATE/pkgs-before"
[ -d /etc/httpd ] && tar -C /etc -cf "$LAB_STATE/httpd.tar" httpd
enabled httpd && state_set httpd-enabled 1
getsebool httpd_enable_cgi 2>/dev/null | awk '{print $NF}' >"$LAB_STATE/cgi"
user_add confined
true
