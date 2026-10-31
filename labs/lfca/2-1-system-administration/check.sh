# The fstab line for /data, comments left out.
line() { awk '$1 !~ /^#/ && $2 == "/data"' /etc/fstab; }
page() {
	local i
	for i in 1 2 3 4 5; do
		[ "$(curl -s -o /dev/null -w '%{http_code}' --max-time 3 http://localhost/)" = 200 ] && return 0
		sleep 2
	done
	return 1
}

task 1 "A sudo user created, checked and deleted" self

task 2 "nginx installed, running, enabled, serving localhost"
need "nginx is installed" 'command -v nginx'
need "nginx starts at boot" enabled nginx
need "nginx is running" active nginx
need "curl localhost gets a page" page

task 3 "/dev/loop40 partitioned, ext4 mounted at /data, in /etc/fstab"
need "/dev/loop40 has a partition" 'lsblk -nro TYPE /dev/loop40 | grep -qx part'
need "/etc/fstab has one line for /data" '[ "$(line | wc -l)" = 1 ]'
need "the line says ext4" '[ "$(line | awk "{print \$3}")" = ext4 ]'
need "/data is mounted from a partition of /dev/loop40" '[[ "$(findmnt -n -o SOURCE /data)" == /dev/loop40p* ]]'
need "/data is ext4" '[ "$(findmnt -n -o FSTYPE /data)" = ext4 ]'

task 4 "A cron job wrote /root/cron-date.txt, and the entry is gone"
need "/root/cron-date.txt has a date in it" 'grep -q "20[0-9][0-9]" /root/cron-date.txt'
need "no crontab entry writes to cron-date.txt any more" '! grep -rqs cron-date /var/spool/cron /etc/crontab /etc/cron.d'
