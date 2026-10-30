command -v atq >/dev/null && for j in $(atq | awk '{print $1}'); do
	at -c "$j" 2>/dev/null | grep -q '/var/tmp/at-' && atrm "$j"
done
systemctl disable --quiet --now datelog.timer 2>/dev/null
systemctl stop datelog.service 2>/dev/null
rm -f /etc/systemd/system/datelog.timer /etc/systemd/system/datelog.service
systemctl daemon-reload
rm -f /var/tmp/at-first /var/tmp/at-second
for f in cron.allow cron.deny; do
	if [ -f "$LAB_STATE/$f" ]; then cp -a "$LAB_STATE/$f" /etc/$f; else rm -f /etc/$f; fi
done
crontab -u alice -r >/dev/null 2>&1
users_remove
true
