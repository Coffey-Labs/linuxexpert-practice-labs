for f in /var/spool/cron/[!c]* /var/spool/cron/crontabs/*; do
	[ -f "$f" ] || continue
	u=${f##*/}
	if grep -qE 'cron-(test|env)' "$f"; then
		crontab -u "$u" -l 2>/dev/null | grep -vE 'cron-(test|env)' | crontab -u "$u" -
	fi
done
if command -v atq >/dev/null; then
	atq 2>/dev/null | awk '{print $1}' | xargs -r atrm 2>/dev/null
fi
if [ -z "$(state_get had-at)" ] && pkg_installed at; then
	systemctl disable --now --quiet atd 2>/dev/null
	if is_rhel; then dnf -y -q remove at >/dev/null; else DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge at >/dev/null 2>&1; fi
elif [ -z "$(state_get atd-active)" ]; then
	systemctl disable --now --quiet atd 2>/dev/null
fi
rm -f /tmp/cron-test.txt /tmp/cron-env.txt /tmp/at-ran
true
