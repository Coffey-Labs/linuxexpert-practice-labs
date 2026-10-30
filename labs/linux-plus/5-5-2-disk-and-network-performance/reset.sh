systemctl disable --now --quiet log-shipper.service 2>/dev/null
rm -rf /etc/systemd/system/log-shipper.service /etc/systemd/system/log-shipper.service.d /var/lib/log-shipper
rm -f /usr/local/lib/le-lab/log-shipper.py
rmdir /usr/local/lib/le-lab 2>/dev/null
systemctl daemon-reload
tc qdisc del dev le-host root 2>/dev/null
pkill -x iperf3 2>/dev/null
if systemctl is-active --quiet firewalld; then
	[ -n "$(state_get port-open)" ] || firewall-cmd -q --remove-port=5201/tcp 2>/dev/null
	[ -n "$(state_get port-open-permanent)" ] || firewall-cmd -q --permanent --remove-port=5201/tcp 2>/dev/null
fi
true
