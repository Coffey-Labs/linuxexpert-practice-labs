rm -f /etc/sudoers.d/le-lab-alice
rm -rf /var/log/webapp
for f in /etc/logrotate.d/*; do
	[ -f "$f" ] || continue
	grep -qxF "${f##*/}" "$LAB_STATE/logrotate-d" 2>/dev/null && continue
	grep -q '/var/log/webapp' "$f" && rm -f "$f"
done
sed -i '\#^"/var/log/webapp/#d' /var/lib/logrotate/status 2>/dev/null
if [ -n "$(state_get installed-rsyslog)" ]; then
	DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge rsyslog >/dev/null 2>&1
fi
true
