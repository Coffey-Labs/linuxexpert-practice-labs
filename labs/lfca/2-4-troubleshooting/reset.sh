findmnt /data >/dev/null && umount -l /data
[ -n "$(state_get had-data)" ] || rmdir /data 2>/dev/null

# nginx as it was.
if [ -n "$(state_get had-nginx)" ]; then
	[ -f "$LAB_STATE/nginx.conf" ] && cp -a "$LAB_STATE/nginx.conf" /etc/nginx/nginx.conf
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
if [ -n "$(state_get no-stress-ng)" ] && pkg_installed stress-ng; then
	if is_rhel; then dnf -y -q remove stress-ng >/dev/null 2>&1; else DEBIAN_FRONTEND=noninteractive apt-get -y -qq --autoremove purge stress-ng >/dev/null 2>&1; fi
fi
true
