if ! pkg_installed cron; then
	pkg_install cron
	state_set installed-cron 1
fi
systemctl enable --now --quiet cron
user_add student
user_add alice
crontab -r -u student 2>/dev/null || true
for f in cron.allow cron.deny; do
	[ -f /etc/$f ] && cp -a /etc/$f "$LAB_STATE/$f"
done
ls /etc/cron.d >"$LAB_STATE/cron-d"
if [ ! -e /usr/local/bin/cleanup ]; then
	cat >/usr/local/bin/cleanup <<'X'
#!/bin/sh
# Practice lab: stands in for a monthly cleanup job.
find /tmp -maxdepth 1 -name 'cleanup-test-*' -mtime +30 -delete
X
	chmod 755 /usr/local/bin/cleanup
	state_set made-cleanup 1
fi
H=$(getent passwd student | cut -d: -f6)
state_set home "$H"
rm -f "$H/ticks.log" "$H/boot.log"
true
