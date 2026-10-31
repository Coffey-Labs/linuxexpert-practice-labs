findmnt /data >/dev/null && refuse "something is mounted at /data; unmount it first"
grep -Eq '^[^#]*[[:space:]]/data[[:space:]]' /etc/fstab && refuse "/etc/fstab already has a line for /data; remove it first"
[ ! -e /root/cron-date.txt ] || refuse "/root/cron-date.txt already exists; move it away first"
[ -d /data ] && state_set had-data 1
if pkg_installed nginx; then
	state_set had-nginx 1
	enabled nginx && state_set nginx-was-enabled 1
	active nginx && state_set nginx-was-active 1
	# Task 2 starts from nginx stopped and off at boot.
	systemctl disable --now --quiet nginx
fi
disk_add 0 1G >/dev/null
