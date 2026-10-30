crontab -u alice -r >/dev/null 2>&1
for f in /etc/systemd/system/*.timer; do
	[ -f "$f" ] || continue
	grep -qxF "$f" "$LAB_STATE/timers-before" 2>/dev/null && continue
	t=${f##*/}
	svc=$(systemctl show -p Unit --value "$t" 2>/dev/null)
	systemctl disable --now --quiet "$t" 2>/dev/null
	rm -f "$f"
	[ -n "$svc" ] && [ -f "/etc/systemd/system/$svc" ] && rm -f "/etc/systemd/system/$svc"
done
systemctl daemon-reload
command -v atq >/dev/null && for j in $(atq | awk '{print $1}'); do atrm "$j"; done
rm -f /tmp/at-ran
true
