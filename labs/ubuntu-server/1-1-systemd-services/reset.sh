systemctl disable --now --quiet hello.service 2>/dev/null
rm -rf /etc/systemd/system/hello.service /etc/systemd/system/hello.service.d
systemctl unmask --quiet nginx.service 2>/dev/null
systemctl daemon-reload
systemctl reset-failed hello.service 2>/dev/null
# The packages installed since the lab started, and only those.
if [ -s "$LAB_STATE/pkgs-before" ]; then
	new=$(dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }' | sort -u |
		comm -13 "$LAB_STATE/pkgs-before" - | grep -Ev '^linux-')
	if [ -n "$new" ]; then
		say "Removing the packages installed since the lab started..."
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge $new >/dev/null 2>&1
	fi
fi
if [ -n "$(state_get had-nginx)" ]; then
	systemctl enable --now --quiet nginx 2>/dev/null
else
	rm -rf /etc/nginx /var/log/nginx /var/www/html/index.nginx-debian.html
fi
true
