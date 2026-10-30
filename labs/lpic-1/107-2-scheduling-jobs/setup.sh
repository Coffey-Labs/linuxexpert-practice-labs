user_add alice
pkg_installed "$(pick cronie cron)" || pkg_install cronie/cron
systemctl enable --quiet --now "$(pick crond cron)"
state_set since "$(date '+%Y-%m-%d %H:%M:%S')"
# Where cron logs, and how much is there already: the journal may not last
# across a reboot.
for f in /var/log/cron /var/log/syslog; do
	[ -f "$f" ] && state_set "size$(echo "$f" | tr / _)" "$(stat -c %s "$f")"
done
# Note the access files so reset can put them back, and start without them.
for f in cron.allow cron.deny; do
	[ -e /etc/$f ] && cp -a /etc/$f "$LAB_STATE/$f"
done
rm -f /etc/cron.allow
[ -e /etc/cron.deny ] && sed -i '/^alice$/d' /etc/cron.deny
crontab -u alice -r >/dev/null 2>&1 || true
rm -f /var/tmp/at-first /var/tmp/at-second
true
