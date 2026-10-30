if systemctl is-active --quiet chronyd || systemctl is-active --quiet chrony; then
	state_set client chrony
elif systemctl is-active --quiet systemd-timesyncd; then
	state_set client timesyncd
elif systemctl is-active --quiet ntpd || systemctl is-active --quiet ntp || systemctl is-active --quiet ntpsec; then
	state_set client ntp
else
	refuse "no NTP client is running; start chronyd or systemd-timesyncd first"
fi
if [ -f /etc/adjtime ] && [ "$(sed -n 3p /etc/adjtime)" = LOCAL ]; then
	state_set rtc local
else
	state_set rtc utc
fi
# chrony's configuration, as it is now.
if pkg_installed chrony; then
	state_set had-chrony 1
	if is_rhel; then cp -a /etc/chrony.conf "$LAB_STATE/chrony.conf"; else tar -C /etc -cf "$LAB_STATE/chrony.tar" chrony; fi
fi
is_debian && pkg_installed systemd-timesyncd && state_set had-timesyncd 1
true
