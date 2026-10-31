for n in 1 2; do
	systemctl disable --now --quiet le-lab-backend$n.service 2>/dev/null
	rm -f /etc/systemd/system/le-lab-backend$n.service
done
systemctl daemon-reload
rm -rf /srv/le-backend1 /srv/le-backend2 /usr/local/lib/le-lab/httpd.py
rmdir /usr/local/lib/le-lab 2>/dev/null

# nginx as it was.
if [ -n "$(state_get had-nginx)" ]; then
	if [ -f "$LAB_STATE/nginx.tar" ]; then
		rm -rf /etc/nginx
		tar -C /etc -xf "$LAB_STATE/nginx.tar"
		command -v restorecon >/dev/null && restorecon -R /etc/nginx
	fi
	if [ -n "$(state_get nginx-was-enabled)" ]; then systemctl enable --quiet nginx; else systemctl disable --quiet nginx 2>/dev/null; fi
	if [ -n "$(state_get nginx-was-active)" ]; then systemctl restart nginx; else systemctl stop nginx 2>/dev/null; fi
elif pkg_installed nginx; then
	systemctl disable --now --quiet nginx 2>/dev/null
	if is_rhel; then
		dnf -y -q remove nginx >/dev/null 2>&1
	else
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq --autoremove purge nginx nginx-common >/dev/null 2>&1
	fi
	rm -rf /etc/nginx
fi

# SELinux booleans as they were.
if [ -s "$LAB_STATE/sebools" ] && command -v setsebool >/dev/null; then
	while read -r b _ v; do
		[ "$(getsebool "$b" 2>/dev/null | awk '{print $3}')" = "$v" ] || setsebool -P "$b" "$v"
	done <"$LAB_STATE/sebools"
fi
true
