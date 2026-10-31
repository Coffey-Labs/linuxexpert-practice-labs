crontab -r -u student 2>/dev/null
crontab -r -u alice 2>/dev/null
H=$(state_get home)
[ -n "$H" ] && rm -f "$H/ticks.log" "$H/boot.log"
for f in cron.allow cron.deny; do
	if [ -f "$LAB_STATE/$f" ]; then cp -a "$LAB_STATE/$f" /etc/$f; else rm -f /etc/$f; fi
done
for f in /etc/cron.d/*; do
	[ -f "$f" ] || continue
	grep -qxF "${f##*/}" "$LAB_STATE/cron-d" 2>/dev/null && continue
	grep -q /usr/local/bin/cleanup "$f" && rm -f "$f"
done
[ -n "$(state_get made-cleanup)" ] && rm -f /usr/local/bin/cleanup
if [ -n "$(state_get installed-cron)" ]; then
	DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge cron >/dev/null 2>&1
fi
true
