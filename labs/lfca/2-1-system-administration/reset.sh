# Cron entries and their file.
if crontab -l 2>/dev/null | grep -q cron-date; then
	crontab -l | grep -v cron-date | crontab -
fi
grep -rls cron-date /etc/cron.d 2>/dev/null | xargs -r rm -f
rm -f /root/cron-date.txt

# /data, before reset removes the disk.
sed -i -E '/^[^#]*[[:space:]]\/data[[:space:]]/d' /etc/fstab
systemctl daemon-reload
findmnt /data >/dev/null && umount -l /data
[ -n "$(state_get had-data)" ] || rmdir /data 2>/dev/null

# nginx as it was.
if [ -n "$(state_get had-nginx)" ]; then
	[ -n "$(state_get nginx-was-enabled)" ] && systemctl enable --quiet nginx
	[ -n "$(state_get nginx-was-enabled)" ] || systemctl disable --quiet nginx 2>/dev/null
	if [ -n "$(state_get nginx-was-active)" ]; then systemctl start nginx; else systemctl stop nginx 2>/dev/null; fi
elif pkg_installed nginx; then
	systemctl disable --now --quiet nginx 2>/dev/null
	if is_rhel; then dnf -y -q remove nginx >/dev/null; else DEBIAN_FRONTEND=noninteractive apt-get -y -qq --autoremove purge nginx nginx-common >/dev/null 2>&1; fi
fi
true
