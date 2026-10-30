user_add alice
user_add bob
pkg_installed "$(pick cronie cron)" || pkg_install cronie/cron
cronsvc=$(pick crond cron)
systemctl enable --quiet --now "$cronsvc"

# Note the access files so reset can put them back.
[ -e /etc/cron.allow ] && state_set had-cron-allow yes
[ -e /etc/cron.deny ] && cp -a /etc/cron.deny "$LAB_STATE/cron.deny"
if [ -e /etc/cron.deny ]; then sed -i '/^bob$/d' /etc/cron.deny; fi
crontab -u alice -r >/dev/null 2>&1 || true
true
