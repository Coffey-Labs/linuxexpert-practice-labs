# The sleep from task 2.
ps -eo pid=,user=,args= | awk '$2 != "root" && $3 == "sleep" && $4 == "1000" && NF == 4 { print $1 }' | xargs -r kill 2>/dev/null
# The packages installed since the lab started, and only those.
if [ -s "$LAB_STATE/pkgs-before" ]; then
	new=$(dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }' | sort -u |
		comm -13 "$LAB_STATE/pkgs-before" - | grep -Ev '^linux-')
	if [ -n "$new" ]; then
		say "Removing the packages installed since the lab started..."
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge $new >/dev/null 2>&1
	fi
fi
if [ -z "$(state_get had-nginx)" ]; then
	rm -rf /etc/nginx /var/log/nginx /var/www/html/index.nginx-debian.html
elif [ -n "$(state_get nginx-was-active)" ]; then
	systemctl start nginx 2>/dev/null
fi
true
