crontab -u alice -r >/dev/null 2>&1
crontab -u bob -r >/dev/null 2>&1
command -v atq >/dev/null && for j in $(atq | awk '{print $1}'); do
	at -c "$j" 2>/dev/null | grep -q at-test && atrm "$j"
done
systemctl disable --quiet --now cleanup.timer 2>/dev/null
rm -f /etc/systemd/system/cleanup.timer /etc/systemd/system/cleanup.service
systemctl daemon-reload
rm -rf /tmp/scratch /tmp/at-test /tmp/alice-date.log
[ "$(state_get had-cron-allow)" = yes ] || rm -f /etc/cron.allow
if [ -f "$LAB_STATE/cron.deny" ]; then cp -a "$LAB_STATE/cron.deny" /etc/cron.deny
else rm -f /etc/cron.deny; fi
true
