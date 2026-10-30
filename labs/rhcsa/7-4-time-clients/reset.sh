if [ -f "$LAB_STATE/chrony.conf" ]; then
	cp -a "$LAB_STATE/chrony.conf" /etc/chrony.conf
	if [ -n "$(state_get chronyd-enabled)" ]; then systemctl restart chronyd; fi
fi
systemctl disable --now --quiet le-lab-ntp1.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-ntp1.service /etc/le-lab/ntp1.conf
systemctl daemon-reload
tz=$(state_get timezone)
[ -n "$tz" ] && timedatectl set-timezone "$tz"
true
