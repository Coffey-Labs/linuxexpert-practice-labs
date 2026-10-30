systemctl disable --now --quiet labbeat.timer 2>/dev/null
rm -f /etc/systemd/system/labbeat.service /etc/systemd/system/labbeat.timer
systemctl unmask --quiet atd 2>/dev/null
systemctl revert atd >/dev/null 2>&1
rm -rf /etc/systemd/system/atd.service.d
systemctl daemon-reload
systemctl reset-failed labbeat.service 2>/dev/null
if [ -z "$(state_get had-at)" ]; then
	systemctl disable --now --quiet atd 2>/dev/null
	if is_rhel; then dnf -y -q remove at >/dev/null; else DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge at >/dev/null 2>&1; fi
elif [ -n "$(state_get atd-enabled)" ]; then
	systemctl enable --now --quiet atd 2>/dev/null
fi
true
