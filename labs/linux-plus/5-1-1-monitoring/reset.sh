systemctl disable --now --quiet le-lab-web.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-web.service
rm -rf /srv/le-web /usr/local/lib/le-lab/httpd.py
rmdir /usr/local/lib/le-lab 2>/dev/null
systemctl daemon-reload
rm -f /root/health.sh /home/*/health.sh
# SNMP: the agent off and its configuration as it was.
if [ -f "$LAB_STATE/snmpd.conf" ]; then
	cp -a "$LAB_STATE/snmpd.conf" /etc/snmp/snmpd.conf
elif [ -f /etc/snmp/snmpd.conf ]; then
	sed -i '/labro/d' /etc/snmp/snmpd.conf
fi
[ -n "$(state_get had-snmpd)" ] || systemctl disable --now --quiet snmpd 2>/dev/null
if systemctl is-active --quiet firewalld; then
	[ -n "$(state_get snmp-open)" ] || firewall-cmd -q --remove-service=snmp 2>/dev/null
	[ -n "$(state_get snmp-open-permanent)" ] || firewall-cmd -q --permanent --remove-service=snmp 2>/dev/null
fi
if [ -n "$(state_get made-journal)" ]; then
	journalctl --relinquish-var 2>/dev/null
	rm -rf /var/log/journal
	systemctl restart systemd-journald
fi
true
